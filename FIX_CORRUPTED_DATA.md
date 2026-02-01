# 🔧 修复 "Corrupted or Malformed" 错误

## ✅ 已完成的修复

1. ✅ 删除了损坏的设备支持文件
2. ✅ 清理了Xcode缓存
3. ✅ 重启了设备服务
4. ✅ 重新打开了Xcode项目

## 📱 现在需要做的

### 方法1: 等待自动下载（推荐）

1. **等待Xcode加载**（30-60秒）
2. **打开设备管理器**
   - 菜单: **Window** > **Devices and Simulators**
   - 或快捷键: **Shift + ⌘ + 2**
3. **查看设备状态**
   - 应该能看到 **YPhone**
   - 状态可能是 "Preparing..." 或 "Waiting..."
4. **等待Xcode下载设备支持**
   - Xcode会自动开始下载iOS 26.2的设备支持文件
   - 这可能需要 **5-10分钟**
   - 确保Mac连接到网络
   - 状态会从 "Preparing..." 变为 "Ready"

### 方法2: 手动下载设备支持（如果自动下载失败）

如果等待10分钟后还是没有进展：

1. **打开Xcode设置**
   - 菜单: **Xcode** > **Settings**（或 **Preferences**）
   - 点击 **Platforms** 标签

2. **下载iOS设备支持**
   - 查找 **iOS 26.2** 或类似的版本
   - 点击 **Download** 按钮
   - 等待下载完成（可能需要较长时间）

3. **或者使用命令行下载**
   ```bash
   # 查看可用的设备支持
   xcodebuild -downloadPlatform iOS
   ```

### 方法3: 使用旧版本设备支持（临时方案）

如果iOS 26.2支持文件下载失败，可以尝试：

1. **检查是否有其他iOS版本的支持文件**
   ```bash
   ls ~/Library/Developer/Xcode/iOS\ DeviceSupport/
   ```

2. **如果有相近版本**（如26.1, 26.0），可以尝试复制：
   ```bash
   # 不推荐，但可以临时使用
   # 最好还是下载正确的版本
   ```

### 方法4: 重置设备连接

如果以上方法都不行：

1. **在设备管理器中**
   - 右键点击 **YPhone**
   - 选择 **Unpair Device**（如果可用）

2. **重新配对**
   - 拔掉USB线，等待10秒
   - 重新插入USB线
   - 在iPhone上确认信任

3. **等待Xcode重新准备设备**

## 🔍 检查下载进度

在设备管理器中，你可以看到：
- **"Preparing..."** - 正在下载/准备
- **"Ready"** - 准备完成，可以使用
- **"Waiting to reconnect"** - 等待重新连接
- **错误信息** - 如果有问题会显示

## ⚠️ 常见问题

### Q: 下载一直卡在 "Preparing..."

**解决**:
1. 检查网络连接
2. 尝试重启Xcode
3. 手动下载设备支持（方法2）
4. 检查防火墙设置（Xcode需要访问Apple服务器）

### Q: 下载失败，显示网络错误

**解决**:
1. 检查网络连接
2. 尝试使用VPN（如果在中国大陆）
3. 更换网络（如使用手机热点）
4. 检查系统代理设置

### Q: 设备显示但无法选择

**解决**:
1. 确保设备状态是 "Ready"
2. 在设备管理器中，点击设备
3. 查看右侧是否有 "Use for Development" 选项
4. 如果显示 "Enable"，点击它

### Q: 还是显示 "Corrupted or Malformed"

**解决**:
1. 再次运行修复脚本：
   ```bash
   ./fix_corrupted_support.sh
   ```
2. 完全重启Mac
3. 更新Xcode到最新版本
4. 检查Xcode日志：
   - 菜单: **Window** > **Organizer**
   - 查看是否有错误信息

## 📋 检查清单

在运行应用前，确保：

- [ ] 设备在设备管理器中显示
- [ ] 设备状态是 "Ready"（不是 "Preparing..."）
- [ ] "Use for Development" 已启用
- [ ] 项目部署目标设置为 15.0（不是 18.0）
- [ ] 代码签名已配置（Signing & Capabilities）
- [ ] Team已选择（你的Apple ID）

## 🚀 如果一切正常

设备准备完成后：

1. **在Xcode顶部选择设备**
   - 点击设备选择器
   - 选择 **YPhone**

2. **配置代码签名**（如果还没配置）
   - 项目 > Signing & Capabilities
   - 勾选 "Automatically manage signing"
   - 选择你的Apple ID

3. **运行应用**
   - 按 **⌘+R** 或点击 **Run** 按钮
   - 应用会自动构建并安装到iPhone

## 💡 提示

- 首次下载设备支持文件可能需要较长时间（5-15分钟）
- 确保Mac连接到稳定的网络
- 如果下载很慢，可以尝试使用VPN
- 下载过程中不要关闭Xcode
- 可以在设备管理器中查看下载进度
