#import <CoreText/CTFontManager.h>
#import <CoreGraphics/CGDataProvider.h>
#import <CoreGraphics/CGFont.h>

const CFStringRef kCTFontManagerRegisteredFontsChangedNotification = CFSTR("CTFontManagerFontChangedNotification");

bool CTFontManagerRegisterGraphicsFont(CGFontRef font, CFErrorRef* error)
{
    printf("STUB %s\n", __PRETTY_FUNCTION__);
    return nil;
}

bool CTFontManagerUnregisterGraphicsFont(CGFontRef font, CFErrorRef *error)
{
    printf("STUB %s\n", __PRETTY_FUNCTION__);
    return nil;
}

CFArrayRef CTFontManagerCopyAvailableFontFamilyNames(void)
{
    printf("STUB %s\n", __PRETTY_FUNCTION__);
    return nil;
}

bool CTFontManagerRegisterFontsForURL(CFURLRef fontURL, CTFontManagerScope scope, CFErrorRef * error)
{
    printf("STUB %s\n", __PRETTY_FUNCTION__);
    return false;
}

CFArrayRef CTFontManagerCreateFontDescriptorsFromData(CFDataRef data)
{
    if (!data) return NULL;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    if (!provider) return NULL;
    CGFontRef font = CGFontCreateWithDataProvider(provider);
    CGDataProviderRelease(provider);
    if (!font) return NULL;
    CFStringRef name = CGFontCopyFullName(font);
    CGFontRelease(font);
    if (!name) return NULL;
    const void *keys[] = { kCTFontNameAttribute };
    const void *values[] = { name };
    CFDictionaryRef attributes = CFDictionaryCreate(kCFAllocatorDefault, keys, values, 1,
        &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFRelease(name);
    if (!attributes) return NULL;
    CTFontDescriptorRef descriptor = CTFontDescriptorCreateWithAttributes(attributes);
    CFRelease(attributes);
    if (!descriptor) return NULL;
    CFArrayRef descriptors = CFArrayCreate(kCFAllocatorDefault, (const void **)&descriptor, 1,
        &kCFTypeArrayCallBacks);
    CFRelease(descriptor);
    return descriptors;
}

CFArrayRef CTFontManagerCreateFontDescriptorsFromURL(CFURLRef url)
{
    if (!url) return NULL;
    CFDataRef data = NULL;
    if (!CFURLCreateDataAndPropertiesFromResource(kCFAllocatorDefault, url, &data, NULL, NULL, NULL)) return NULL;
    CFArrayRef descriptors = CTFontManagerCreateFontDescriptorsFromData(data);
    CFRelease(data);
    return descriptors;
}
