# 📱 不通过Xcode直接安装到iPhone

由于Xcode的设备支持文件问题，你可以使用命令行直接安装应用。

## 方法1: 使用命令行脚本（推荐）

### 快速安装

```bash
cd /Users/yuhuahuan/code/EHExam
./install_simple.sh
```

这个脚本会：
1. 自动找到你的iPhone
2. 构建应用
3. 直接安装到设备

### 详细安装

```bash
cd /Users/yuhuahuan/code/EHExam
./install_without_xcode.sh
```

## 方法2: 手动使用命令行

### 步骤1: 获取设备UDID

```bash
xcrun devicectl list devices
```

找到你的YPhone的UDID（第三列）

### 步骤2: 构建应用

```bash
cd /Users/yuhuahuan/code/EHExam
xcodebuild -project EHExam.xcodeproj \
           -scheme EHExam \
           -configuration Debug \
           -destination "id=你的设备UDID" \
           -derivedDataPath ./build \
           clean build
```

### 步骤3: 安装应用

```bash
# 找到构建的.app文件
APP_PATH=$(find ./build -name "*.app" -type d | head -1)

# 安装到设备
xcrun devicectl device install app --device "你的设备UDID" "$APP_PATH"
```

## 方法3: 使用ios-deploy（如果devicectl失败）

### 安装ios-deploy

```bash
# 使用npm
npm install -g ios-deploy

# 或使用Homebrew
brew install ios-deploy
```

### 使用ios-deploy安装

```bash
# 构建应用（同上）
xcodebuild -project EHExam.xcodeproj \
           -scheme EHExam \
           -configuration Debug \
           -destination "id=你的设备UDID" \
           -derivedDataPath ./build \
           clean build

# 使用ios-deploy安装
APP_PATH=$(find ./build -name "*.app" -type d | head -1)
ios-deploy --bundle "$APP_PATH"
```

## 方法4: 使用Xcode命令行（绕过GUI）

```bash
cd /Users/yuhuahuan/code/EHExam

# 获取设备UDID
DEVICE_UDID=$(xcrun devicectl list devices | grep "YPhone" | awk '{print $3}')

# 构建并运行（不通过GUI）
xcodebuild -project EHExam.xcodeproj \
           -scheme EHExam \
           -configuration Debug \
           -destination "id=$DEVICE_UDID" \
           build

# 然后手动安装
APP_PATH=$(find ./build -name "*.app" -type d | head -1)
xcrun devicectl device install app --device "$DEVICE_UDID" "$APP_PATH"
```

## 常见问题

### Q: 提示"未找到设备"

**解决**:
1. 确保iPhone已通过USB连接
2. 确保iPhone已解锁
3. 在iPhone上信任此电脑
4. 运行 `xcrun devicectl list devices` 检查

### Q: 安装失败，提示签名错误

**解决**:
1. 确保在Xcode中已配置代码签名
2. 确保选择了正确的Team
3. 检查证书是否有效

### Q: 应用安装后无法打开

**解决**:
1. 在iPhone上: 设置 > 通用 > VPN与设备管理
2. 找到你的开发者证书
3. 点击"信任"

## 优势

使用命令行安装的优势：
- ✅ 绕过Xcode的设备支持文件问题
- ✅ 不需要等待设备准备
- ✅ 可以自动化
- ✅ 更快更直接

## 提示

- 首次安装后，需要在iPhone上信任开发者证书
- 如果应用无法打开，检查设置中的信任状态
- 可以创建一个别名来快速安装：
  ```bash
  alias install-ehexam='cd /Users/yuhuahuan/code/EHExam && ./install_simple.sh'
  ```
