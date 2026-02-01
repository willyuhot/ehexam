# 🔧 修复设备连接问题

## 问题: "Previous preparation error: The data being read was corrupted or malformed"

这个错误通常是因为Xcode的设备支持文件损坏导致的。

## 快速修复

运行自动修复脚本：

```bash
cd /Users/yuhuahuan/code/EHExam
./fix_device_connection.sh
```

## 手动修复步骤

### 步骤1: 关闭Xcode

完全退出Xcode：
- 按 `⌘+Q` 退出Xcode
- 或在终端运行: `killall Xcode`

### 步骤2: 清理损坏的文件

在终端运行：

```bash
# 清理设备支持文件
rm -rf ~/Library/Developer/Xcode/iOS\ DeviceSupport/*

# 清理构建缓存
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# 清理Xcode偏好设置
rm ~/Library/Preferences/com.apple.dt.Xcode.plist
```

### 步骤3: 重启设备服务

```bash
# 重启设备服务
sudo killall -9 usbmuxd
sudo killall -9 com.apple.AMPDeviceDiscoveryAgent
```

### 步骤4: 重新连接iPhone

1. **拔掉USB线**，等待5秒
2. **重新插入USB线**
3. **解锁iPhone**
4. 如果出现"信任此电脑"提示，点击**信任**
5. 输入iPhone密码

### 步骤5: 重新打开Xcode

```bash
cd /Users/yuhuahuan/code/EHExam
open EHExam.xcodeproj
```

### 步骤6: 等待设备准备

1. 在Xcode中，打开 **Window** > **Devices and Simulators**
2. 查看你的iPhone状态
3. 如果显示"Preparing"，**等待完成**（可能需要几分钟）
4. 不要中断这个过程

## 如果仍然无法检测到设备

### 方法1: 检查USB连接

1. 尝试**不同的USB端口**
2. 尝试**不同的USB线**
3. 确保使用**原装或MFi认证的USB线**
4. 避免使用USB Hub，直接连接到Mac

### 方法2: 重启设备

1. **重启iPhone**: 按住电源键和音量键直到出现滑动关机
2. **重启Mac**: 苹果菜单 > 重启
3. 重新连接设备

### 方法3: 检查iPhone设置

1. 在iPhone上: **设置** > **通用** > **关于本机**
2. 滚动到底部，查看是否有"信任此电脑"选项
3. 如果有，点击并信任

### 方法4: 使用Xcode的设备管理器

1. 在Xcode中: **Window** > **Devices and Simulators**
2. 点击左侧的**Devices**
3. 查看你的iPhone是否在列表中
4. 如果显示错误，点击设备，查看详细信息
5. 尝试点击**"Use for Development"**按钮

### 方法5: 检查系统权限

确保Xcode有必要的权限：

1. **系统设置** > **隐私与安全性**
2. 检查以下权限：
   - **开发者工具**: 确保Xcode已授权
   - **完全磁盘访问**: 如果需要

## 使用模拟器（临时方案）

如果真机连接一直有问题，可以先用模拟器测试：

1. 在Xcode顶部设备选择器中
2. 选择 **iPhone 15 Simulator** 或任何模拟器
3. 按 `⌘+R` 运行

应用功能完全相同，只是运行在模拟器上。

## 验证设备连接

运行以下命令检查设备：

```bash
# 列出所有设备
xcrun xctrace list devices

# 检查USB设备
system_profiler SPUSBDataType | grep -i "iphone"
```

如果命令能检测到设备，说明连接正常，问题可能在Xcode配置。

## 常见错误信息

### "This device is not registered"

**解决**: 在Xcode中: Window > Devices and Simulators > 选择设备 > 点击"Use for Development"

### "Could not find Developer Disk Image"

**解决**: 
1. 更新Xcode到最新版本
2. 或更新iPhone到最新iOS版本
3. 或两者都更新

### "Device is busy"

**解决**: 
1. 关闭iPhone上所有应用
2. 重启iPhone
3. 重新连接

## 需要帮助？

如果以上方法都不行：

1. 检查Xcode版本是否与iOS版本兼容
2. 尝试更新Xcode: App Store > 更新
3. 尝试更新macOS
4. 查看Xcode控制台的详细错误信息
