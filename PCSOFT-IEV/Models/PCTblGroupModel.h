// To parse this JSON:
//
//   NSError *error;
//   PCTblGroupModel *tblGroupModel = PCTblGroupModelFromJSON(json, NSUTF8Encoding, &error);

#import <Foundation/Foundation.h>

@class PCTblGroupModelElement;

NS_ASSUME_NONNULL_BEGIN

typedef NSMutableArray<PCTblGroupModelElement *> PCTblGroupModel;

#pragma mark - Top-level marshaling functions

PCTblGroupModel *_Nullable PCTblGroupModelFromData(NSData *data, NSError **error);
PCTblGroupModel *_Nullable PCTblGroupModelFromJSON(NSString *json, NSStringEncoding encoding, NSError **error);
NSData          *_Nullable PCTblGroupModelToData(PCTblGroupModel *tblGroupModel, NSError **error);
NSString        *_Nullable PCTblGroupModelToJSON(PCTblGroupModel *tblGroupModel, NSStringEncoding encoding, NSError **error);

#pragma mark - Object interfaces

@interface PCTblGroupModelElement : NSObject
@property (nonatomic, nullable, copy)   NSString *code;
@property (nonatomic, nullable, copy)   NSString *cursymbl;
@property (nonatomic, nullable, copy)   NSString *dborcr;
@property (nonatomic, nullable, copy)   NSString *descr;
@property (nonatomic, nullable, copy)   NSString *imLot;
@property (nonatomic, nullable, strong) NSNumber *lineTaxes;
@property (nonatomic, nullable, copy)   NSString *partyName;
@property (nonatomic, nullable, strong) NSNumber *qty;
@property (nonatomic, nullable, strong) NSNumber *rate;
@property (nonatomic, nullable, copy)   NSString *rdocNo;
@property (nonatomic, nullable, copy)   NSString *rdocType;
@property (nonatomic, nullable, copy)   NSString *subdesc;
@property (nonatomic, nullable, strong) NSNumber *total;
@property (nonatomic, nullable, strong) NSNumber *value;
@end

NS_ASSUME_NONNULL_END
