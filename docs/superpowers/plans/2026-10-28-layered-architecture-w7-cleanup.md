# 分层架构迁移 · 第 7 阶段（W7 收尾）实施计划

**Goal:** 移除最后一份 Riverpod 残留：删除 `lib/state/`、把 `ResultsPager` 移入 results feature、从依赖中移除 `flutter_riverpod`，确认测试全部走 get_it 注入。

## 完成项

- `lib/state/results_pager.dart` → `lib/ui/features/results/view_models/results_pager.dart`；`lib/state/` 目录删除
- `pubspec.yaml` 移除 `flutter_riverpod`；`flutter pub get` 后 `pubspec.lock` 不再包含 `riverpod` / `state_notifier`
- `lib/` 与 `test/` 中无 `flutter_riverpod` / `ProviderScope` / `ref.*` / `ConsumerWidget` / `ConsumerState`
- 测试统一使用 `test/helpers/test_di.dart` 的 `setupTestDi` + `resetDi`；不再有 ProviderScope 脚手架
- 文档：`HANDOVER.md` 状态管理改为 ChangeNotifier + get_it；`AGENTS.md` 的设置项接线说明同步

## 验收

- `dart analyze lib/ test/` 无问题
- `flutter test` 全绿：473 passed / 15 skipped（唯一变动的 skip 是原先环境限制的 `mode switch hydration` 组，现在可稳定运行）
- 真实网络用例仍保持 skip

## Self-Review

- W0–W7 的波次边界：W3 纯移动、W4–W6 状态迁移、W7 依赖收尾；每波独立提交，均可回退。
- 未做实机验证：UI 行为由 widget 测试覆盖，按 spec 在全部波次完成后统一安排一次主流程实机验收。
