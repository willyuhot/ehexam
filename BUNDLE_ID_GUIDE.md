# Bundle ID 问题解决指南

## 问题说明

错误信息：
```
Failed Registering Bundle Identifier: The app identifier "com.ehexam.EHExam" cannot be registered to your development team because it is not available.
```

这意味着 `com.ehexam.EHExam` 这个Bundle ID已经被其他开发者使用，或者需要先在App Store Connect中注册。

## 解决方案

### 方案一：使用唯一的Bundle ID（推荐）

修改Bundle ID为包含你的信息的唯一标识符：

1. **使用你的域名**（如果有）：
   ```
   com.yourdomain.EHExam
   ```

2. **使用你的名字**：
   ```
   com.yuhuahuan.EHExam
   ```

3. **使用时间戳**（已自动生成）：
   ```
   com.ehexam.EHExam.yuhuahuan.1234567890
   ```

### 方案二：在App Store Connect中注册Bundle ID

1. 登录 https://appstoreconnect.apple.com
2. 进入 **"我的App"**
3. 点击 **"+"** 创建新App
4. 填写信息：
   - **平台**: iOS
   - **名称**: EHExam
   - **主要语言**: 简体中文
   - **Bundle ID**: 选择或创建 `com.ehexam.EHExam`
   - **SKU**: EHExam-001（唯一标识符）

5. 如果Bundle ID不存在，需要先在Certificates, Identifiers & Profiles中创建：
   - 登录 https://developer.apple.com/account/resources/identifiers/list
   - 点击 **"+"** 添加新标识符
   - 选择 **"App IDs"**
   - 选择 **"App"**
   - 填写描述和Bundle ID
   - 注册

### 方案三：修改project.yml使用自定义Bundle ID

编辑 `project.yml`：

```yaml
targets:
  EHExam:
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.yourname.EHExam  # 改为你的唯一标识符
```

然后重新生成项目：
```bash
rm -rf EHExam.xcodeproj
xcodegen generate
```

## 快速修复

运行自动修复脚本：
```bash
./fix_bundle_id.sh
```

这会自动生成一个包含时间戳的唯一Bundle ID。

## 注意事项

- ⚠️ Bundle ID一旦在App Store Connect中注册，就不能更改
- ⚠️ 每个Bundle ID在Apple Developer账号中是唯一的
- ⚠️ 如果使用TestFlight，Bundle ID必须与App Store Connect中的App匹配

## 推荐做法

对于个人开发，建议使用：
```
com.[你的名字或域名].EHExam
```

例如：
- `com.yuhuahuan.EHExam`
- `com.yourdomain.EHExam`
- `com.ehexam.EHExam.personal`
