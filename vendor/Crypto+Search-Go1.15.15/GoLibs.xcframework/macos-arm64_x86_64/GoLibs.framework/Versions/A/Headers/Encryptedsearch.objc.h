// Objective-C API for talking to github.com/ProtonMail/go-encrypted-search/encryptedsearch Go package.
//   gobind -lang=objc github.com/ProtonMail/go-encrypted-search/encryptedsearch
//
// File is generated by gobind. Do not edit.

#ifndef __Encryptedsearch_H__
#define __Encryptedsearch_H__

@import Foundation;
#include "ref.h"
#include "Universe.objc.h"


@class EncryptedsearchAESGCMCipher;
@class EncryptedsearchCache;
@class EncryptedsearchDBParams;
@class EncryptedsearchDecryptedMessageContent;
@class EncryptedsearchEncryptedMessageContent;
@class EncryptedsearchIndex;
@class EncryptedsearchMessage;
@class EncryptedsearchNormalizer;
@class EncryptedsearchRecipient;
@class EncryptedsearchRecipientList;
@class EncryptedsearchResultList;
@class EncryptedsearchSearchResult;
@class EncryptedsearchSearchState;
@class EncryptedsearchSimpleSearcher;
@class EncryptedsearchStringList;
@protocol EncryptedsearchCipher;
@class EncryptedsearchCipher;
@protocol EncryptedsearchSearcher;
@class EncryptedsearchSearcher;

@protocol EncryptedsearchCipher <NSObject>
- (BOOL)clearKey;
- (EncryptedsearchDecryptedMessageContent* _Nullable)decrypt:(EncryptedsearchEncryptedMessageContent* _Nullable)p0 error:(NSError* _Nullable* _Nullable)error;
- (EncryptedsearchEncryptedMessageContent* _Nullable)encrypt:(EncryptedsearchDecryptedMessageContent* _Nullable)p0 error:(NSError* _Nullable* _Nullable)error;
@end

@protocol EncryptedsearchSearcher <NSObject>
- (EncryptedsearchSearchResult* _Nullable)search:(EncryptedsearchMessage* _Nullable)msg error:(NSError* _Nullable* _Nullable)error;
@end

/**
 * AESGCMCipher encrypts messages using the AES-GCM cipher.
 */
@interface EncryptedsearchAESGCMCipher : NSObject <goSeqRefInterface, EncryptedsearchCipher> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
/**
 * NewAESGCMCipher initialize the cipher with the bytes of an aes key.
 */
- (nullable instancetype)init:(NSData* _Nullable)key;
/**
 * ClearKey removes the cipher key from memory.
 */
- (BOOL)clearKey;
/**
 * Decrypt decrypts the message content.
 */
- (EncryptedsearchDecryptedMessageContent* _Nullable)decrypt:(EncryptedsearchEncryptedMessageContent* _Nullable)encryptedContent error:(NSError* _Nullable* _Nullable)error;
/**
 * Encrypt encrypts the message content.
 */
- (EncryptedsearchEncryptedMessageContent* _Nullable)encrypt:(EncryptedsearchDecryptedMessageContent* _Nullable)plainMsg error:(NSError* _Nullable* _Nullable)error;
@end

/**
 * Cache keeps the decrypted message in memory.
 */
@interface EncryptedsearchCache : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
/**
 * NewCache is a constructor for the Cache struct.
maxSize sets the maximum size of the cache (in bytes).
 */
- (nullable instancetype)init:(int64_t)maxSize;
/**
 * CacheIndex connects to the sqlite db containing the messages.
It loads and decrypts messages until it is full.
 */
- (BOOL)cacheIndex:(EncryptedsearchDBParams* _Nullable)dbParams cipher:(id<EncryptedsearchCipher> _Nullable)cipher batchSize:(long)batchSize error:(NSError* _Nullable* _Nullable)error;
/**
 * DeleteAll : deletes the cached messages.
 */
- (void)deleteAll;
/**
 * DeleteMessage deletes the message with the corresponding id from the cache.
 */
- (BOOL)deleteMessage:(NSString* _Nullable)id_;
/**
 * GetLastIDCached returns the id of the last message cached.
 */
- (NSString* _Nonnull)getLastIDCached;
/**
 * GetLastTimeCached returns the time of the last message cached.
 */
- (int64_t)getLastTimeCached;
/**
 * GetLength returns the number of messages cached.
 */
- (long)getLength;
/**
 * GetSize returns the approximate size in bytes of the cache.
 */
- (int64_t)getSize;
- (BOOL)hasMessage:(NSString* _Nullable)id_;
/**
 * IsBuilt whether the cache was initialized.
 */
- (BOOL)isBuilt;
/**
 * IsPartial whether the cache contains all the messages or only a part.
 */
- (BOOL)isPartial;
/**
 * Search goes through the cached messages with the provided searcher
and updates the provided result list.
 */
- (EncryptedsearchResultList* _Nullable)search:(EncryptedsearchSearchState* _Nullable)state searcher:(id<EncryptedsearchSearcher> _Nullable)searcher batchSize:(long)batchSize error:(NSError* _Nullable* _Nullable)error;
/**
 * UpdateCache adds a new message to the cache,
or overwrites if one with the same id is cached.
 */
- (void)updateCache:(EncryptedsearchMessage* _Nullable)messageToInsert;
@end

/**
 * DBParams The parameters needed to query the index db.
 */
@interface EncryptedsearchDBParams : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
/**
 * NewDBParams Creates a new object with the database parameters.
 */
- (nullable instancetype)init:(NSString* _Nullable)file table:(NSString* _Nullable)table id_:(NSString* _Nullable)id_ time:(NSString* _Nullable)time order:(NSString* _Nullable)order labels:(NSString* _Nullable)labels initVector:(NSString* _Nullable)initVector content:(NSString* _Nullable)content contentFile:(NSString* _Nullable)contentFile;
@end

/**
 * DecryptedMessageContent the decrypted message content that is used for search.
 */
@interface EncryptedsearchDecryptedMessageContent : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
/**
 * NewDecryptedMessageContent creates a new decrypted message content.
 */
- (nullable instancetype)init:(NSString* _Nullable)subjectValue senderValue:(EncryptedsearchRecipient* _Nullable)senderValue bodyValue:(NSString* _Nullable)bodyValue toListValue:(EncryptedsearchRecipientList* _Nullable)toListValue ccListValue:(EncryptedsearchRecipientList* _Nullable)ccListValue bccListValue:(EncryptedsearchRecipientList* _Nullable)bccListValue addressID:(NSString* _Nullable)addressID conversationID:(NSString* _Nullable)conversationID flags:(int64_t)flags unread:(BOOL)unread isStarred:(BOOL)isStarred isReplied:(BOOL)isReplied isRepliedAll:(BOOL)isRepliedAll isForwarded:(BOOL)isForwarded numAttachments:(long)numAttachments expirationTime:(int64_t)expirationTime;
@property (nonatomic) NSString* _Nonnull subject;
@property (nonatomic) EncryptedsearchRecipient* _Nullable sender;
@property (nonatomic) NSString* _Nonnull body;
@property (nonatomic) EncryptedsearchRecipientList* _Nullable toList;
@property (nonatomic) EncryptedsearchRecipientList* _Nullable ccList;
@property (nonatomic) EncryptedsearchRecipientList* _Nullable bccList;
@property (nonatomic) NSString* _Nonnull addressID;
@property (nonatomic) NSString* _Nonnull conversationID;
@property (nonatomic) int64_t flags;
@property (nonatomic) BOOL unread;
@property (nonatomic) BOOL isStarred;
@property (nonatomic) BOOL isReplied;
@property (nonatomic) BOOL isRepliedAll;
@property (nonatomic) BOOL isForwarded;
@property (nonatomic) long numAttachments;
@property (nonatomic) int64_t expirationTime;
@end

/**
 * EncryptedMessageContent the iv and ciphertext encrypting the message content.
 */
@interface EncryptedsearchEncryptedMessageContent : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
/**
 * NewEncryptedMessageContent creates a new encrypted content object.
 */
- (nullable instancetype)init:(NSString* _Nullable)ivBase64 ciphertextBase64:(NSString* _Nullable)ciphertextBase64;
@property (nonatomic) NSString* _Nonnull iv;
@property (nonatomic) NSString* _Nonnull ciphertext;
@end

/**
 * Index a golang wrapper for the index db
that supports caching and searching the indexed message.
 */
@interface EncryptedsearchIndex : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
/**
 * NewIndex creates a new index.
 */
- (nullable instancetype)init:(EncryptedsearchDBParams* _Nullable)params;
- (BOOL)closeDBConnection:(NSError* _Nullable* _Nullable)error;
- (BOOL)openDBConnection:(NSError* _Nullable* _Nullable)error;
- (EncryptedsearchResultList* _Nullable)searchNewBatchFromDB:(id<EncryptedsearchSearcher> _Nullable)searcher cipher:(id<EncryptedsearchCipher> _Nullable)cipher state:(EncryptedsearchSearchState* _Nullable)state batchSize:(long)batchSize error:(NSError* _Nullable* _Nullable)error;
@end

/**
 * Message a message information to search.
 */
@interface EncryptedsearchMessage : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
/**
 * NewMessage creates a new message.
 */
- (nullable instancetype)init:(NSString* _Nullable)idValue timeValue:(int64_t)timeValue orderValue:(int64_t)orderValue labelidsValue:(NSString* _Nullable)labelidsValue encryptedValue:(EncryptedsearchEncryptedMessageContent* _Nullable)encryptedValue decryptedValue:(EncryptedsearchDecryptedMessageContent* _Nullable)decryptedValue;
@property (nonatomic) NSString* _Nonnull id_;
@property (nonatomic) int64_t time;
@property (nonatomic) int64_t order;
@property (nonatomic) NSString* _Nonnull labelIds;
@property (nonatomic) EncryptedsearchEncryptedMessageContent* _Nullable encryptedContent;
@property (nonatomic) EncryptedsearchDecryptedMessageContent* _Nullable decryptedContent;
@end

@interface EncryptedsearchNormalizer : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) BOOL normalizeApostrophes;
/**
 * NormalizeString returns a lower case, without
diacritics version of the given string.
 */
- (NSString* _Nonnull)normalizeString:(NSString* _Nullable)value;
@end

/**
 * Recipient a pair (name, email) of a user.
 */
@interface EncryptedsearchRecipient : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
/**
 * NewRecipient creates a new recipient.
 */
- (nullable instancetype)init:(NSString* _Nullable)name email:(NSString* _Nullable)email;
@property (nonatomic) NSString* _Nonnull name;
@property (nonatomic) NSString* _Nonnull email;
@end

/**
 * RecipientList a wrapper for a list of recipients.
 */
@interface EncryptedsearchRecipientList : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
/**
 * Add adds a recipient to the list.
 */
- (void)add:(EncryptedsearchRecipient* _Nullable)user;
/**
 * Get returns the recipient at the index, or nil.
 */
- (EncryptedsearchRecipient* _Nullable)get:(long)index;
/**
 * Length the number of recipients in the list.
 */
- (long)length;
@end

/**
 * ResultList is a wrapper for a list of SearchResult objects
and also holds some information on the search.
 */
@interface EncryptedsearchResultList : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nullable instancetype)init;
- (void)add:(EncryptedsearchSearchResult* _Nullable)result;
- (BOOL)deleteResult:(NSString* _Nullable)id_;
/**
 * Get returns the result at the given index or nil.
 */
- (EncryptedsearchSearchResult* _Nullable)get:(long)index;
- (long)length;
- (void)sortByTime;
- (void)updateResult:(EncryptedsearchSearchResult* _Nullable)resultToUpdate;
@end

/**
 * SearchResult encapsulates the list of match found in a message,
or an error encountered while searching.
 */
@interface EncryptedsearchSearchResult : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
/**
 * NewSearchResult initialize a search result with no match.
 */
- (nullable instancetype)init:(EncryptedsearchMessage* _Nullable)msg;
@property (nonatomic) EncryptedsearchMessage* _Nullable message;
@property (nonatomic) BOOL valid;
- (NSString* _Nonnull)getBodyPreview;
/**
 * GetError returns an error if the search failed, nil otherwise.
 */
- (BOOL)getError:(NSError* _Nullable* _Nullable)error;
@end

@interface EncryptedsearchSearchState : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nullable instancetype)init;
@property (nonatomic) long searchedCount;
@property (nonatomic) long cacheSearchedCount;
@property (nonatomic) NSString* _Nonnull lastIDSearched;
@property (nonatomic) int64_t lastTimeSearched;
@property (nonatomic) BOOL cachedSearchDone;
@property (nonatomic) BOOL isComplete;
@end

/**
 * GoSearcher a searcher that uses the golang.org/x/text/search package.
 */
@interface EncryptedsearchSimpleSearcher : NSObject <goSeqRefInterface, EncryptedsearchSearcher> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
/**
 * NewGoSearcher creates a new go searcher with the appropriate language support
and keywords to look for. It also needs the size of the context to return in results and a cipher
to decrypt messages.
 */
- (nullable instancetype)init:(EncryptedsearchStringList* _Nullable)keywords contextSize:(long)contextSize;
/**
 * Search looks through the (encrypted or decrypted) content of a message to find the needed keywords,
It returns a search result object with all the matches it found.
 */
- (EncryptedsearchSearchResult* _Nullable)search:(EncryptedsearchMessage* _Nullable)msg error:(NSError* _Nullable* _Nullable)error;
@end

/**
 * StringList is a wrapper on []string to be used by mobile apps.
 */
@interface EncryptedsearchStringList : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
/**
 * Add appends a new element at the end of the list.
 */
- (void)add:(NSString* _Nullable)word;
/**
 * Get returns the element at index i in the list, or "" if it's out of bound.
 */
- (NSString* _Nonnull)get:(long)index error:(NSError* _Nullable* _Nullable)error;
/**
 * Length returns the number of elements in the list.
 */
- (long)length;
@end

/**
 * NewAESGCMCipher initialize the cipher with the bytes of an aes key.
 */
FOUNDATION_EXPORT EncryptedsearchAESGCMCipher* _Nullable EncryptedsearchNewAESGCMCipher(NSData* _Nullable key, NSError* _Nullable* _Nullable error);

/**
 * NewCache is a constructor for the Cache struct.
maxSize sets the maximum size of the cache (in bytes).
 */
FOUNDATION_EXPORT EncryptedsearchCache* _Nullable EncryptedsearchNewCache(int64_t maxSize, NSError* _Nullable* _Nullable error);

/**
 * NewDBParams Creates a new object with the database parameters.
 */
FOUNDATION_EXPORT EncryptedsearchDBParams* _Nullable EncryptedsearchNewDBParams(NSString* _Nullable file, NSString* _Nullable table, NSString* _Nullable id_, NSString* _Nullable time, NSString* _Nullable order, NSString* _Nullable labels, NSString* _Nullable initVector, NSString* _Nullable content, NSString* _Nullable contentFile);

/**
 * NewDecryptedMessageContent creates a new decrypted message content.
 */
FOUNDATION_EXPORT EncryptedsearchDecryptedMessageContent* _Nullable EncryptedsearchNewDecryptedMessageContent(NSString* _Nullable subjectValue, EncryptedsearchRecipient* _Nullable senderValue, NSString* _Nullable bodyValue, EncryptedsearchRecipientList* _Nullable toListValue, EncryptedsearchRecipientList* _Nullable ccListValue, EncryptedsearchRecipientList* _Nullable bccListValue, NSString* _Nullable addressID, NSString* _Nullable conversationID, int64_t flags, BOOL unread, BOOL isStarred, BOOL isReplied, BOOL isRepliedAll, BOOL isForwarded, long numAttachments, int64_t expirationTime);

/**
 * NewEncryptedMessageContent creates a new encrypted content object.
 */
FOUNDATION_EXPORT EncryptedsearchEncryptedMessageContent* _Nullable EncryptedsearchNewEncryptedMessageContent(NSString* _Nullable ivBase64, NSString* _Nullable ciphertextBase64);

/**
 * NewIndex creates a new index.
 */
FOUNDATION_EXPORT EncryptedsearchIndex* _Nullable EncryptedsearchNewIndex(EncryptedsearchDBParams* _Nullable params, NSError* _Nullable* _Nullable error);

/**
 * NewMessage creates a new message.
 */
FOUNDATION_EXPORT EncryptedsearchMessage* _Nullable EncryptedsearchNewMessage(NSString* _Nullable idValue, int64_t timeValue, int64_t orderValue, NSString* _Nullable labelidsValue, EncryptedsearchEncryptedMessageContent* _Nullable encryptedValue, EncryptedsearchDecryptedMessageContent* _Nullable decryptedValue);

/**
 * NewRecipient creates a new recipient.
 */
FOUNDATION_EXPORT EncryptedsearchRecipient* _Nullable EncryptedsearchNewRecipient(NSString* _Nullable name, NSString* _Nullable email);

FOUNDATION_EXPORT EncryptedsearchResultList* _Nullable EncryptedsearchNewResultList(void);

/**
 * NewSearchResult initialize a search result with no match.
 */
FOUNDATION_EXPORT EncryptedsearchSearchResult* _Nullable EncryptedsearchNewSearchResult(EncryptedsearchMessage* _Nullable msg, NSError* _Nullable* _Nullable error);

FOUNDATION_EXPORT EncryptedsearchSearchState* _Nullable EncryptedsearchNewSearchState(void);

/**
 * NewGoSearcher creates a new go searcher with the appropriate language support
and keywords to look for. It also needs the size of the context to return in results and a cipher
to decrypt messages.
 */
FOUNDATION_EXPORT EncryptedsearchSimpleSearcher* _Nullable EncryptedsearchNewSimpleSearcher(EncryptedsearchStringList* _Nullable keywords, long contextSize);

@class EncryptedsearchCipher;

@class EncryptedsearchSearcher;

/**
 * Cipher an interface of objects that can encrypt and decrypt messages.
 */
@interface EncryptedsearchCipher : NSObject <goSeqRefInterface, EncryptedsearchCipher> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (BOOL)clearKey;
- (EncryptedsearchDecryptedMessageContent* _Nullable)decrypt:(EncryptedsearchEncryptedMessageContent* _Nullable)p0 error:(NSError* _Nullable* _Nullable)error;
- (EncryptedsearchEncryptedMessageContent* _Nullable)encrypt:(EncryptedsearchDecryptedMessageContent* _Nullable)p0 error:(NSError* _Nullable* _Nullable)error;
@end

/**
 * Searcher interface for an object that can search a message.
 */
@interface EncryptedsearchSearcher : NSObject <goSeqRefInterface, EncryptedsearchSearcher> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (EncryptedsearchSearchResult* _Nullable)search:(EncryptedsearchMessage* _Nullable)msg error:(NSError* _Nullable* _Nullable)error;
@end

#endif
