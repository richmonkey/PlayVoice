#!/bin/bash

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📱 GoogleSignInDemo 项目设置${NC}\n"

# 1. 检查 Xcode
echo -e "${YELLOW}✓ 检查 Xcode...${NC}"
if ! command -v xcode-select &> /dev/null; then
    echo -e "${RED}❌ Xcode 未安装${NC}"
    echo "请访问 App Store 安装 Xcode"
    exit 1
fi
XCODE_PATH=$(xcode-select -p)
echo -e "${GREEN}✓ Xcode 已安装: $XCODE_PATH${NC}\n"

# 2. 检查并安装 XcodeGen
echo -e "${YELLOW}✓ 检查 XcodeGen...${NC}"
if ! command -v xcodegen &> /dev/null; then
    echo -e "${YELLOW}📦 安装 XcodeGen...${NC}"
    brew install xcodegen
fi
XCODEGEN_VERSION=$(xcodegen version)
echo -e "${GREEN}✓ XcodeGen 已安装: $XCODEGEN_VERSION${NC}\n"

# 3. 清理旧的构建缓存
echo -e "${YELLOW}✓ 清理旧构建缓存...${NC}"
rm -rf ~/Library/Developer/Xcode/DerivedData/GoogleSignInDemo-* 2>/dev/null || true
echo -e "${GREEN}✓ 缓存已清理${NC}\n"

# 4. 生成 Xcode 项目
echo -e "${YELLOW}✓ 生成 Xcode 项目配置...${NC}"
xcodegen generate
echo -e "${GREEN}✓ 项目配置已生成${NC}\n"

# 5. 显示后续步骤
echo -e "${GREEN}✅ 设置完成！${NC}\n"
echo -e "${BLUE}后续步骤：${NC}"
echo ""
echo "  1. 打开项目："
echo -e "     ${YELLOW}open GoogleSignInDemo.xcodeproj${NC}"
echo ""
echo "  2. 在 Xcode 中："
echo -e "     - 选择目标设备（iPhone 15 Pro 或其他模拟器）"
echo -e "     - 按 ${YELLOW}Cmd+B${NC} 构建项目"
echo -e "     - 按 ${YELLOW}Cmd+R${NC} 运行项目"
echo ""
echo "  3. 更多信息："
echo -e "     - 查看 ${YELLOW}BUILD_SETUP.md${NC} 了解详细构建指南"
echo -e "     - 查看 ${YELLOW}MIGRATION_GUIDE.md${NC} 了解依赖迁移"
echo -e "     - 查看 ${YELLOW}CLAUDE.md${NC} 了解项目架构"
echo ""

# 6. 询问是否打开项目
read -p "是否立即打开项目? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open GoogleSignInDemo.xcodeproj
    echo -e "${GREEN}✓ 项目已在 Xcode 中打开${NC}"
fi
