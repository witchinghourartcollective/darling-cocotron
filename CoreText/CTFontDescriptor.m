#import <CoreText/CTFontDescriptor.h>

#include <CoreFoundation/CFDictionary.h>
#include <stdlib.h>

const CFStringRef kCTFontURLAttribute = CFSTR("NSCTFontFileURLAttribute");
const CFStringRef kCTFontNameAttribute = CFSTR("NSFontNameAttribute");
const CFStringRef kCTFontDisplayNameAttribute = CFSTR("NSFontVisibleNameAttribute");
const CFStringRef kCTFontFamilyNameAttribute = CFSTR("NSFontFamilyAttribute");
const CFStringRef kCTFontStyleNameAttribute = CFSTR("NSFontFaceAttribute");
const CFStringRef kCTFontTraitsAttribute = CFSTR("NSCTFontTraitsAttribute");
const CFStringRef kCTFontVariationAttribute = CFSTR("NSCTFontVariationAttribute");
const CFStringRef kCTFontSizeAttribute = CFSTR("NSFontSizeAttribute");
const CFStringRef kCTFontMatrixAttribute = CFSTR("NSCTFontMatrixAttribute");
const CFStringRef kCTFontCascadeListAttribute = CFSTR("NSCTFontCascadeListAttribute");
const CFStringRef kCTFontCharacterSetAttribute = CFSTR("NSCTFontCharacterSetAttribute");
const CFStringRef kCTFontLanguagesAttribute = CFSTR("NSCTFontLanguagesAttribute");
const CFStringRef kCTFontBaselineAdjustAttribute = CFSTR("NSCTFontBaselineAdjustAttribute");
const CFStringRef kCTFontMacintoshEncodingsAttribute = CFSTR("NSCTFontMacintoshEncodingsAttribute");
const CFStringRef kCTFontFeaturesAttribute = CFSTR("NSCTFontFeaturesAttribute");
const CFStringRef kCTFontFeatureSettingsAttribute = CFSTR("NSCTFontFeatureSettingsAttribute");
const CFStringRef kCTFontFixedAdvanceAttribute = CFSTR("NSCTFontFixedAdvanceAttribute");
const CFStringRef kCTFontOrientationAttribute = CFSTR("NSCTFontOrientationAttribute");
const CFStringRef kCTFontEnabledAttribute = CFSTR("NSCTFontEnabledAttribute");
const CFStringRef kCTFontFormatAttribute = CFSTR("NSCTFontFormatAttribute");
const CFStringRef kCTFontRegistrationScopeAttribute = CFSTR("NSCTFontRegistrationScopeAttribute");
const CFStringRef kCTFontPriorityAttribute = CFSTR("NSCTFontPriorityAttribute");

CFTypeRef CTFontDescriptorCopyAttribute(CTFontDescriptorRef descriptor, CFStringRef attribute)
{
    if (!descriptor || !attribute) return NULL;
    const void *value = CFDictionaryGetValue((CFDictionaryRef)descriptor, attribute);
    return value ? CFRetain(value) : NULL;
}

CFDictionaryRef CTFontDescriptorCopyAttributes(CTFontDescriptorRef descriptor)
{
    if (!descriptor) return NULL;
    return CFDictionaryCreateCopy(kCFAllocatorDefault, (CFDictionaryRef)descriptor);
}

CTFontDescriptorRef CTFontDescriptorCreateWithAttributes(CFDictionaryRef attributes)
{
    if (!attributes) {
        CFMutableDictionaryRef empty = CFDictionaryCreateMutable(kCFAllocatorDefault, 0,
            &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        return (CTFontDescriptorRef)empty;
    }
    return (CTFontDescriptorRef)CFDictionaryCreateCopy(kCFAllocatorDefault, attributes);
}

CTFontDescriptorRef CTFontDescriptorCreateCopyWithAttributes(CTFontDescriptorRef original, CFDictionaryRef attributes)
{
    if (!original) return NULL;
    CFMutableDictionaryRef merged = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0,
        (CFDictionaryRef)original);
    if (!merged) return NULL;
    if (attributes) {
        CFIndex count = CFDictionaryGetCount(attributes);
        const void **keys = count ? calloc((size_t)count, sizeof(*keys)) : NULL;
        const void **values = count ? calloc((size_t)count, sizeof(*values)) : NULL;
        if (count && (!keys || !values)) {
            free(keys);
            free(values);
            CFRelease(merged);
            return NULL;
        }
        CFDictionaryGetKeysAndValues(attributes, keys, values);
        for (CFIndex i = 0; i < count; i++) {
            CFDictionarySetValue(merged, keys[i], values[i]);
        }
        free(keys);
        free(values);
    }
    return (CTFontDescriptorRef)merged;
}

CFTypeID CTFontDescriptorGetTypeID(void)
{
    return CFDictionaryGetTypeID();
}

static Boolean hasMandatoryAttributes(CTFontDescriptorRef descriptor, CFSetRef mandatoryAttributes)
{
    if (!mandatoryAttributes) return true;
    CFIndex count = CFSetGetCount(mandatoryAttributes);
    const void **keys = count ? calloc((size_t)count, sizeof(*keys)) : NULL;
    if (count && !keys) return false;
    CFSetGetValues(mandatoryAttributes, keys);
    Boolean matches = true;
    for (CFIndex i = 0; i < count; i++) {
        if (!CFDictionaryContainsKey((CFDictionaryRef)descriptor, keys[i])) {
            matches = false;
            break;
        }
    }
    free(keys);
    return matches;
}

CTFontDescriptorRef CTFontDescriptorCreateMatchingFontDescriptor(CTFontDescriptorRef descriptor, CFSetRef mandatoryAttributes)
{
    if (!descriptor || !hasMandatoryAttributes(descriptor, mandatoryAttributes)) return NULL;
    return CTFontDescriptorCreateCopyWithAttributes(descriptor, NULL);
}

CFArrayRef CTFontDescriptorCreateMatchingFontDescriptors(CTFontDescriptorRef descriptor, CFSetRef mandatoryAttributes)
{
    CTFontDescriptorRef match = CTFontDescriptorCreateMatchingFontDescriptor(descriptor, mandatoryAttributes);
    if (!match) return NULL;
    CFArrayRef matches = CFArrayCreate(kCFAllocatorDefault, (const void **)&match, 1, &kCFTypeArrayCallBacks);
    CFRelease(match);
    return matches;
}
