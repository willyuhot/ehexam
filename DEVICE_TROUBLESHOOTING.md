# 🔧 设备连接问题排查指南

## 错误信息
"The data being read was corrupted or malformed. The data couldn't be read because it is missing."

## ✅ 已修复的问题

1. ✅ **iOS部署目标** - 已从18.0改回15.0（18.0版本不存在）
2. ✅ **项目格式** - 已修复为兼容Xcode 15.4的格式
3. ✅ **Xcode缓存** - 已清理

## 📱 设备连接问题解决步骤

### 方法1: 快速修复（推荐）

运行修复脚本：
```bash
cd /Users/yuhuahuan/code/EHExam
./fix_corrupted_data.sh
```

### 方法2: 手动修复

#### 步骤1: 重新连接设备

1. **拔掉USB线**，等待5秒
2. **重新插入USB线**
3. **在iPhone上**：
   - 如果提示"信任此电脑"，点击 **信任**
   - 输入iPhone密码确认
   - 确保iPhone已解锁

#### 步骤2: 在Xcode中检查设备

1. **打开Xcode项目**（如果还没打开）
   ```bash
   open EHExam.xcodeproj
   ```

2. **检查设备管理器**
   - 在Xcode菜单: **Window** > **Devices and Simulators**
   - 查看你的iPhone是否在列表中
   - 检查设备状态（应该显示"Connected"）

3. **如果设备显示但状态异常**：
   - 点击设备名称
   - 查看右侧的状态信息
   - 如果有错误提示，按照提示操作

#### 步骤3: 修复设备支持

如果设备显示但无法使用：

1. **删除设备支持文件**（Xcode会自动重新下载）
   ```bash
   rm -rf ~/Library/Developer/Xcode/iOS\ DeviceSupport/*
   ```

2. **重启Xcode**
   - 完全退出Xcode（⌘+Q）
   - 重新打开项目

3. **重新连接设备**
   - Xcode会自动下载设备支持文件
   - 等待下载完成（可能需要几分钟）

#### 步骤4: 检查设备信任

在iPhone上：
1. **设置** > **通用** > **VPN与设备管理**（或**设备管理**）
2. 查看是否有你的Mac的证书
3. 如果没有，重新连接USB并信任

#### 步骤5: 使用命令行检查

```bash
# 检查设备连接
xcrun xctrace list devices

# 应该看到类似：
# YPhone (26.2.1) (00008150-00094C411AC1401C)
```

如果看不到设备，说明USB连接或信任有问题。

## 🔍 常见问题

### Q: 设备在Finder中能看到，但Xcode看不到

**解决**:
1. 确保iPhone已解锁
2. 在iPhone上信任此电脑
3. 重启Xcode
4. 尝试不同的USB端口

### Q: 设备显示但显示"准备中"或错误

**解决**:
1. 等待Xcode下载设备支持文件（可能需要几分钟）
2. 检查网络连接（Xcode需要下载支持文件）
3. 手动下载：Xcode > Settings > Platforms > 下载对应iOS版本

### Q: "Previous preparation error"

**解决**:
1. 运行修复脚本：`./fix_corrupted_data.sh`
2. 删除设备支持文件并重新连接
3. 重启Mac（如果问题持续）

### Q: 设备显示但无法选择

**解决**:
1. 检查项目部署目标（应该是15.0，不是18.0）
2. 确保iPhone的iOS版本 >= 15.0
3. 在项目设置中检查：项目 > General > Minimum Deployments

## 📋 检查清单

在运行应用前，确保：

- [ ] iPhone已通过USB连接到Mac
- [ ] iPhone已解锁
- [ ] iPhone已信任此电脑
- [ ] Xcode中能看到设备（Window > Devices and Simulators）
- [ ] 项目部署目标设置为15.0（不是18.0）
- [ ] 代码签名已配置（Signing & Capabilities）
- [ ] Team已选择（你的Apple ID）

## 🚀 如果所有方法都失败

1. **重启Mac和iPhone**
2. **使用不同的USB线**
3. **尝试不同的USB端口**
4. **更新Xcode到最新版本**
5. **检查iPhone的iOS版本**（确保 >= 15.0）

## 💡 提示

- 首次连接设备时，Xcode需要下载设备支持文件，这可能需要几分钟
- 确保Mac和iPhone都连接到稳定的网络（用于下载支持文件）
- 如果使用USB Hub，尝试直接连接到Mac的USB端口
