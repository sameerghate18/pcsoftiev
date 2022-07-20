#import "PCTblGroupModel.h"

// Shorthand for simple blocks
#define λ(decl, expr) (^(decl) { return (expr); })

// nil → NSNull conversion for JSON dictionaries
static id NSNullify(id _Nullable x) {
    return (x == nil || x == NSNull.null) ? NSNull.null : x;
}

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private model interfaces

@interface PCTblGroupModelElement (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

static id map(id collection, id (^f)(id value)) {
    id result = nil;
    if ([collection isKindOfClass:NSArray.class]) {
        result = [NSMutableArray arrayWithCapacity:[collection count]];
        for (id x in collection) [result addObject:f(x)];
    } else if ([collection isKindOfClass:NSDictionary.class]) {
        result = [NSMutableDictionary dictionaryWithCapacity:[collection count]];
        for (id key in collection) [result setObject:f([collection objectForKey:key]) forKey:key];
    }
    return result;
}

#pragma mark - JSON serialization

PCTblGroupModel *_Nullable PCTblGroupModelFromData(NSData *data, NSError **error)
{
    @try {
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
        return *error ? nil : map(json, λ(id x, [PCTblGroupModelElement fromJSONDictionary:x]));
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
}

PCTblGroupModel *_Nullable PCTblGroupModelFromJSON(NSString *json, NSStringEncoding encoding, NSError **error)
{
    return PCTblGroupModelFromData([json dataUsingEncoding:encoding], error);
}

NSData *_Nullable PCTblGroupModelToData(PCTblGroupModel *tblGroupModel, NSError **error)
{
    @try {
        id json = map(tblGroupModel, λ(id x, [x JSONDictionary]));
        NSData *data = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:error];
        return *error ? nil : data;
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
}

NSString *_Nullable PCTblGroupModelToJSON(PCTblGroupModel *tblGroupModel, NSStringEncoding encoding, NSError **error)
{
    NSData *data = PCTblGroupModelToData(tblGroupModel, error);
    return data ? [[NSString alloc] initWithData:data encoding:encoding] : nil;
}

@implementation PCTblGroupModelElement
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"code": @"code",
        @"cursymbl": @"cursymbl",
        @"dborcr": @"dborcr",
        @"descr": @"descr",
        @"im_lot": @"imLot",
        @"line_taxes": @"lineTaxes",
        @"party_name": @"partyName",
        @"qty": @"qty",
        @"rate": @"rate",
        @"rdoc_no": @"rdocNo",
        @"rdoc_type": @"rdocType",
        @"subdesc": @"subdesc",
        @"total": @"total",
        @"value": @"value",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    return dict ? [[PCTblGroupModelElement alloc] initWithJSONDictionary:dict] : nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (void)setValue:(nullable id)value forKey:(NSString *)key
{
    id resolved = PCTblGroupModelElement.properties[key];
    if (resolved) [super setValue:value forKey:resolved];
}

- (void)setNilValueForKey:(NSString *)key
{
    id resolved = PCTblGroupModelElement.properties[key];
    if (resolved) [super setValue:@(0) forKey:resolved];
}

- (NSDictionary *)JSONDictionary
{
    id dict = [[self dictionaryWithValuesForKeys:PCTblGroupModelElement.properties.allValues] mutableCopy];

    // Rewrite property names that differ in JSON
    for (id jsonName in PCTblGroupModelElement.properties) {
        id propertyName = PCTblGroupModelElement.properties[jsonName];
        if (![jsonName isEqualToString:propertyName]) {
            dict[jsonName] = dict[propertyName];
            [dict removeObjectForKey:propertyName];
        }
    }

    return dict;
}
@end

NS_ASSUME_NONNULL_END
