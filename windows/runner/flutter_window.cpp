#include "flutter_window.h"

#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <optional>
#include <commdlg.h>
#include <shellapi.h>

#include "flutter/generated_plugin_registrant.h"
#include "utils.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  // 將 Kallopis 視窗列動作接到 Windows 原生視窗管理 API。
  auto window_channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(), "kallopis/window",
          &flutter::StandardMethodCodec::GetInstance());

  HWND const hwnd = GetHandle();
  window_channel->SetMethodCallHandler(
      [this, hwnd](
          const flutter::MethodCall<flutter::EncodableValue>& call,
          std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
              result) {
        if (call.method_name() == "minimize") {
          ShowWindow(hwnd, SW_MINIMIZE);
          result->Success();
        } else if (call.method_name() == "maximize") {
          ShowWindow(hwnd, IsZoomed(hwnd) ? SW_RESTORE : SW_MAXIMIZE);
          result->Success();
        } else if (call.method_name() == "drag") {
          ReleaseCapture();
          SendMessage(hwnd, WM_NCLBUTTONDOWN, HTCAPTION, 0);
          result->Success();
        } else if (call.method_name() == "setMinSize") {
          const auto* arguments =
              std::get_if<flutter::EncodableMap>(call.arguments());
          if (arguments != nullptr) {
            int width = 0;
            int height = 0;
            auto width_entry =
                arguments->find(flutter::EncodableValue("width"));
            if (width_entry != arguments->end() &&
                !width_entry->second.IsNull()) {
              if (std::holds_alternative<int32_t>(width_entry->second)) {
                width = std::get<int32_t>(width_entry->second);
              } else if (std::holds_alternative<int64_t>(
                             width_entry->second)) {
                width =
                    static_cast<int>(std::get<int64_t>(width_entry->second));
              } else if (std::holds_alternative<double>(
                             width_entry->second)) {
                width =
                    static_cast<int>(std::get<double>(width_entry->second));
              }
            }

            auto height_entry =
                arguments->find(flutter::EncodableValue("height"));
            if (height_entry != arguments->end() &&
                !height_entry->second.IsNull()) {
              if (std::holds_alternative<int32_t>(height_entry->second)) {
                height = std::get<int32_t>(height_entry->second);
              } else if (std::holds_alternative<int64_t>(
                             height_entry->second)) {
                height = static_cast<int>(
                    std::get<int64_t>(height_entry->second));
              } else if (std::holds_alternative<double>(
                             height_entry->second)) {
                height =
                    static_cast<int>(std::get<double>(height_entry->second));
              }
            }
            SetMinSize(width, height);
          }
          result->Success();
        } else if (call.method_name() == "close") {
          PostMessage(hwnd, WM_CLOSE, 0, 0);
          result->Success();
        } else if (call.method_name() == "isMaximized") {
          result->Success(flutter::EncodableValue(IsZoomed(hwnd) != 0));
        } else {
          result->NotImplemented();
        }
      });

  // 將 Windows 選檔與拖放路徑轉成單一 Dart file intent，不在 runner 讀取內容。
  file_intent_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(), "notist/file_intent",
          &flutter::StandardMethodCodec::GetInstance());
  file_intent_channel_->SetMethodCallHandler(
      [hwnd](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
                 result) {
        if (call.method_name() != "pickMarkdownFile") {
          result->NotImplemented();
          return;
        }
        std::vector<wchar_t> path(32768, L'\0');
        OPENFILENAMEW dialog{};
        dialog.lStructSize = sizeof(dialog);
        dialog.hwndOwner = hwnd;
        dialog.lpstrFile = path.data();
        dialog.nMaxFile = static_cast<DWORD>(path.size());
        dialog.lpstrFilter = L"Markdown (*.md)\0*.md\0\0";
        dialog.Flags = OFN_FILEMUSTEXIST | OFN_PATHMUSTEXIST;
        if (::GetOpenFileNameW(&dialog)) {
          result->Success(flutter::EncodableValue(Utf8FromUtf16(path.data())));
        } else {
          result->Success();
        }
      });
  ::DragAcceptFiles(hwnd, TRUE);

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  if (message == WM_NCHITTEST) {
    return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
  }

  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_DROPFILES: {
      HDROP drop = reinterpret_cast<HDROP>(wparam);
      const UINT count = ::DragQueryFileW(drop, 0xFFFFFFFF, nullptr, 0);
      flutter::EncodableList paths;
      for (UINT index = 0; index < count; ++index) {
        const UINT length = ::DragQueryFileW(drop, index, nullptr, 0);
        std::vector<wchar_t> path(length + 1, L'\0');
        if (::DragQueryFileW(drop, index, path.data(), length + 1) > 0) {
          paths.emplace_back(Utf8FromUtf16(path.data()));
        }
      }
      ::DragFinish(drop);
      if (file_intent_channel_ && !paths.empty()) {
        file_intent_channel_->InvokeMethod(
            "openMarkdownFiles",
            std::make_unique<flutter::EncodableValue>(paths));
      }
      return 0;
    }
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
