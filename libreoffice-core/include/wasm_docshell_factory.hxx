#pragma once
#include <rtl/ustring.hxx>
#include <com/sun/star/beans/PropertyValue.hpp>
#include <com/sun/star/uno/Sequence.hxx>

namespace css = com::sun::star;

namespace wasm{
// 工厂函数
// 根据 URL 和 InFilterName 选择 DocShell 类型，同时返回默认的 PDF 导出过滤器名
class SfxObjectShell;
SfxObjectShell* createDocShellForUrl(const OUString& sURL,
    const OUString& inFilter,
    OUString& outExportFilter);

// 执行转换
// 在 desktop 层执行完整的加载与保存（PDF→Office 或 Office→PDF）
bool performConversion(const OUString& sURL,
    const css::uno::Sequence<css::beans::PropertyValue>& loadProps,
    const OUString& inFilter,
    const OUString& outFilter,
    const OUString& outURL);
}// namespace wasm
