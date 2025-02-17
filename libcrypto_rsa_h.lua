local ffi = require'ffi'
--[[
// csrc/openssl/src/include/openssl/rsa.h
enum {
	OPENSSL_RSA_MAX_MODULUS_BITS = 16384,
	OPENSSL_RSA_FIPS_MIN_MODULUS_BITS = 1024,
	OPENSSL_RSA_SMALL_MODULUS_BITS = 3072,
	OPENSSL_RSA_MAX_PUBEXP_BITS = 64,
	RSA_3                = 0x3L,
	RSA_F4               = 0x10001L,
	RSA_ASN1_VERSION_DEFAULT = 0,
	RSA_ASN1_VERSION_MULTI = 1,
	RSA_DEFAULT_PRIME_NUM = 2,
	RSA_METHOD_FLAG_NO_CHECK = 0x0001,
	RSA_FLAG_CACHE_PUBLIC = 0x0002,
	RSA_FLAG_CACHE_PRIVATE = 0x0004,
	RSA_FLAG_BLINDING    = 0x0008,
	RSA_FLAG_THREAD_SAFE = 0x0010,
	RSA_FLAG_EXT_PKEY    = 0x0020,
	RSA_FLAG_NO_BLINDING = 0x0080,
	RSA_FLAG_NO_CONSTTIME = 0x0000,
	RSA_FLAG_NO_EXP_CONSTTIME = RSA_FLAG_NO_CONSTTIME,
};
#define EVP_PKEY_CTX_set_rsa_padding(ctx,pad) RSA_pkey_ctx_ctrl(ctx, -1, EVP_PKEY_CTRL_RSA_PADDING, pad, NULL)
#define EVP_PKEY_CTX_get_rsa_padding(ctx,ppad) RSA_pkey_ctx_ctrl(ctx, -1, EVP_PKEY_CTRL_GET_RSA_PADDING, 0, ppad)
#define EVP_PKEY_CTX_set_rsa_pss_saltlen(ctx,len) RSA_pkey_ctx_ctrl(ctx, (EVP_PKEY_OP_SIGN|EVP_PKEY_OP_VERIFY), EVP_PKEY_CTRL_RSA_PSS_SALTLEN, len, NULL)
enum {
	RSA_PSS_SALTLEN_DIGEST = -1,
	RSA_PSS_SALTLEN_AUTO = -2,
	RSA_PSS_SALTLEN_MAX  = -3,
	RSA_PSS_SALTLEN_MAX_SIGN = -2,
};
#define EVP_PKEY_CTX_set_rsa_pss_keygen_saltlen(ctx,len) EVP_PKEY_CTX_ctrl(ctx, EVP_PKEY_RSA_PSS, EVP_PKEY_OP_KEYGEN, EVP_PKEY_CTRL_RSA_PSS_SALTLEN, len, NULL)
#define EVP_PKEY_CTX_get_rsa_pss_saltlen(ctx,plen) RSA_pkey_ctx_ctrl(ctx, (EVP_PKEY_OP_SIGN|EVP_PKEY_OP_VERIFY), EVP_PKEY_CTRL_GET_RSA_PSS_SALTLEN, 0, plen)
#define EVP_PKEY_CTX_set_rsa_keygen_bits(ctx,bits) RSA_pkey_ctx_ctrl(ctx, EVP_PKEY_OP_KEYGEN, EVP_PKEY_CTRL_RSA_KEYGEN_BITS, bits, NULL)
#define EVP_PKEY_CTX_set_rsa_keygen_pubexp(ctx,pubexp) RSA_pkey_ctx_ctrl(ctx, EVP_PKEY_OP_KEYGEN, EVP_PKEY_CTRL_RSA_KEYGEN_PUBEXP, 0, pubexp)
#define EVP_PKEY_CTX_set_rsa_keygen_primes(ctx,primes) RSA_pkey_ctx_ctrl(ctx, EVP_PKEY_OP_KEYGEN, EVP_PKEY_CTRL_RSA_KEYGEN_PRIMES, primes, NULL)
#define EVP_PKEY_CTX_set_rsa_mgf1_md(ctx,md) RSA_pkey_ctx_ctrl(ctx, EVP_PKEY_OP_TYPE_SIG | EVP_PKEY_OP_TYPE_CRYPT, EVP_PKEY_CTRL_RSA_MGF1_MD, 0, (void *)(md))
#define EVP_PKEY_CTX_set_rsa_pss_keygen_mgf1_md(ctx,md) EVP_PKEY_CTX_ctrl(ctx, EVP_PKEY_RSA_PSS, EVP_PKEY_OP_KEYGEN, EVP_PKEY_CTRL_RSA_MGF1_MD, 0, (void *)(md))
#define EVP_PKEY_CTX_set_rsa_oaep_md(ctx,md) EVP_PKEY_CTX_ctrl(ctx, EVP_PKEY_RSA, EVP_PKEY_OP_TYPE_CRYPT, EVP_PKEY_CTRL_RSA_OAEP_MD, 0, (void *)(md))
#define EVP_PKEY_CTX_get_rsa_mgf1_md(ctx,pmd) RSA_pkey_ctx_ctrl(ctx, EVP_PKEY_OP_TYPE_SIG | EVP_PKEY_OP_TYPE_CRYPT, EVP_PKEY_CTRL_GET_RSA_MGF1_MD, 0, (void *)(pmd))
#define EVP_PKEY_CTX_get_rsa_oaep_md(ctx,pmd) EVP_PKEY_CTX_ctrl(ctx, EVP_PKEY_RSA, EVP_PKEY_OP_TYPE_CRYPT, EVP_PKEY_CTRL_GET_RSA_OAEP_MD, 0, (void *)(pmd))
#define EVP_PKEY_CTX_set0_rsa_oaep_label(ctx,l,llen) EVP_PKEY_CTX_ctrl(ctx, EVP_PKEY_RSA, EVP_PKEY_OP_TYPE_CRYPT, EVP_PKEY_CTRL_RSA_OAEP_LABEL, llen, (void *)(l))
#define EVP_PKEY_CTX_get0_rsa_oaep_label(ctx,l) EVP_PKEY_CTX_ctrl(ctx, EVP_PKEY_RSA, EVP_PKEY_OP_TYPE_CRYPT, EVP_PKEY_CTRL_GET_RSA_OAEP_LABEL, 0, (void *)(l))
#define EVP_PKEY_CTX_set_rsa_pss_keygen_md(ctx,md) EVP_PKEY_CTX_ctrl(ctx, EVP_PKEY_RSA_PSS, EVP_PKEY_OP_KEYGEN, EVP_PKEY_CTRL_MD, 0, (void *)(md))
enum {
	EVP_PKEY_CTRL_RSA_PADDING = (EVP_PKEY_ALG_CTRL + 1),
	EVP_PKEY_CTRL_RSA_PSS_SALTLEN = (EVP_PKEY_ALG_CTRL + 2),
	EVP_PKEY_CTRL_RSA_KEYGEN_BITS = (EVP_PKEY_ALG_CTRL + 3),
	EVP_PKEY_CTRL_RSA_KEYGEN_PUBEXP = (EVP_PKEY_ALG_CTRL + 4),
	EVP_PKEY_CTRL_RSA_MGF1_MD = (EVP_PKEY_ALG_CTRL + 5),
	EVP_PKEY_CTRL_GET_RSA_PADDING = (EVP_PKEY_ALG_CTRL + 6),
	EVP_PKEY_CTRL_GET_RSA_PSS_SALTLEN = (EVP_PKEY_ALG_CTRL + 7),
	EVP_PKEY_CTRL_GET_RSA_MGF1_MD = (EVP_PKEY_ALG_CTRL + 8),
	EVP_PKEY_CTRL_RSA_OAEP_MD = (EVP_PKEY_ALG_CTRL + 9),
	EVP_PKEY_CTRL_RSA_OAEP_LABEL = (EVP_PKEY_ALG_CTRL + 10),
	EVP_PKEY_CTRL_GET_RSA_OAEP_MD = (EVP_PKEY_ALG_CTRL + 11),
	EVP_PKEY_CTRL_GET_RSA_OAEP_LABEL = (EVP_PKEY_ALG_CTRL + 12),
	EVP_PKEY_CTRL_RSA_KEYGEN_PRIMES = (EVP_PKEY_ALG_CTRL + 13),
	RSA_PKCS1_PADDING    = 1,
	RSA_SSLV23_PADDING   = 2,
	RSA_NO_PADDING       = 3,
	RSA_PKCS1_OAEP_PADDING = 4,
	RSA_X931_PADDING     = 5,
	RSA_PKCS1_PSS_PADDING = 6,
	RSA_PKCS1_PADDING_SIZE = 11,
};
#define RSA_set_app_data(s,arg) RSA_set_ex_data(s,0,arg)
#define RSA_get_app_data(s) RSA_get_ex_data(s,0)
RSA *RSA_new(void);
RSA *RSA_new_method(ENGINE *engine);
int RSA_bits(const RSA *rsa);
int RSA_size(const RSA *rsa);
int RSA_security_bits(const RSA *rsa);
int RSA_set0_key(RSA *r, BIGNUM *n, BIGNUM *e, BIGNUM *d);
int RSA_set0_factors(RSA *r, BIGNUM *p, BIGNUM *q);
int RSA_set0_crt_params(RSA *r,BIGNUM *dmp1, BIGNUM *dmq1, BIGNUM *iqmp);
int RSA_set0_multi_prime_params(RSA *r, BIGNUM *primes[], BIGNUM *exps[],
                                BIGNUM *coeffs[], int pnum);
void RSA_get0_key(const RSA *r,
                  const BIGNUM **n, const BIGNUM **e, const BIGNUM **d);
void RSA_get0_factors(const RSA *r, const BIGNUM **p, const BIGNUM **q);
int RSA_get_multi_prime_extra_count(const RSA *r);
int RSA_get0_multi_prime_factors(const RSA *r, const BIGNUM *primes[]);
void RSA_get0_crt_params(const RSA *r,
                         const BIGNUM **dmp1, const BIGNUM **dmq1,
                         const BIGNUM **iqmp);
int RSA_get0_multi_prime_crt_params(const RSA *r, const BIGNUM *exps[],
                                    const BIGNUM *coeffs[]);
const BIGNUM *RSA_get0_n(const RSA *d);
const BIGNUM *RSA_get0_e(const RSA *d);
const BIGNUM *RSA_get0_d(const RSA *d);
const BIGNUM *RSA_get0_p(const RSA *d);
const BIGNUM *RSA_get0_q(const RSA *d);
const BIGNUM *RSA_get0_dmp1(const RSA *r);
const BIGNUM *RSA_get0_dmq1(const RSA *r);
const BIGNUM *RSA_get0_iqmp(const RSA *r);
void RSA_clear_flags(RSA *r, int flags);
int RSA_test_flags(const RSA *r, int flags);
void RSA_set_flags(RSA *r, int flags);
int RSA_get_version(RSA *r);
ENGINE *RSA_get0_engine(const RSA *r);
RSA *RSA_generate_key(int bits, unsigned long e, void (*callback) (int, int, void *), void *cb_arg) __attribute__ ((deprecated));
int RSA_generate_key_ex(RSA *rsa, int bits, BIGNUM *e, BN_GENCB *cb);
int RSA_generate_multi_prime_key(RSA *rsa, int bits, int primes,
                                 BIGNUM *e, BN_GENCB *cb);
int RSA_X931_derive_ex(RSA *rsa, BIGNUM *p1, BIGNUM *p2, BIGNUM *q1,
                       BIGNUM *q2, const BIGNUM *Xp1, const BIGNUM *Xp2,
                       const BIGNUM *Xp, const BIGNUM *Xq1, const BIGNUM *Xq2,
                       const BIGNUM *Xq, const BIGNUM *e, BN_GENCB *cb);
int RSA_X931_generate_key_ex(RSA *rsa, int bits, const BIGNUM *e,
                             BN_GENCB *cb);
int RSA_check_key(const RSA *);
int RSA_check_key_ex(const RSA *, BN_GENCB *cb);
int RSA_public_encrypt(int flen, const unsigned char *from,
                       unsigned char *to, RSA *rsa, int padding);
int RSA_private_encrypt(int flen, const unsigned char *from,
                        unsigned char *to, RSA *rsa, int padding);
int RSA_public_decrypt(int flen, const unsigned char *from,
                       unsigned char *to, RSA *rsa, int padding);
int RSA_private_decrypt(int flen, const unsigned char *from,
                        unsigned char *to, RSA *rsa, int padding);
void RSA_free(RSA *r);
int RSA_up_ref(RSA *r);
int RSA_flags(const RSA *r);
void RSA_set_default_method(const RSA_METHOD *meth);
const RSA_METHOD *RSA_get_default_method(void);
const RSA_METHOD *RSA_null_method(void);
const RSA_METHOD *RSA_get_method(const RSA *rsa);
int RSA_set_method(RSA *rsa, const RSA_METHOD *meth);
const RSA_METHOD *RSA_PKCS1_OpenSSL(void);
int RSA_pkey_ctx_ctrl(EVP_PKEY_CTX *ctx, int optype, int cmd, int p1, void *p2);
RSA *d2i_RSAPublicKey(RSA **a, const unsigned char **in, long len); int i2d_RSAPublicKey(const RSA *a, unsigned char **out); const ASN1_ITEM * RSAPublicKey_it(void);
RSA *d2i_RSAPrivateKey(RSA **a, const unsigned char **in, long len); int i2d_RSAPrivateKey(const RSA *a, unsigned char **out); const ASN1_ITEM * RSAPrivateKey_it(void);
typedef struct rsa_pss_params_st {
    X509_ALGOR *hashAlgorithm;
    X509_ALGOR *maskGenAlgorithm;
    ASN1_INTEGER *saltLength;
    ASN1_INTEGER *trailerField;
    X509_ALGOR *maskHash;
} RSA_PSS_PARAMS;
RSA_PSS_PARAMS *RSA_PSS_PARAMS_new(void); void RSA_PSS_PARAMS_free(RSA_PSS_PARAMS *a); RSA_PSS_PARAMS *d2i_RSA_PSS_PARAMS(RSA_PSS_PARAMS **a, const unsigned char **in, long len); int i2d_RSA_PSS_PARAMS(RSA_PSS_PARAMS *a, unsigned char **out); const ASN1_ITEM * RSA_PSS_PARAMS_it(void);
typedef struct rsa_oaep_params_st {
    X509_ALGOR *hashFunc;
    X509_ALGOR *maskGenFunc;
    X509_ALGOR *pSourceFunc;
    X509_ALGOR *maskHash;
} RSA_OAEP_PARAMS;
RSA_OAEP_PARAMS *RSA_OAEP_PARAMS_new(void); void RSA_OAEP_PARAMS_free(RSA_OAEP_PARAMS *a); RSA_OAEP_PARAMS *d2i_RSA_OAEP_PARAMS(RSA_OAEP_PARAMS **a, const unsigned char **in, long len); int i2d_RSA_OAEP_PARAMS(RSA_OAEP_PARAMS *a, unsigned char **out); const ASN1_ITEM * RSA_OAEP_PARAMS_it(void);
int RSA_print_fp(FILE *fp, const RSA *r, int offset);
int RSA_print(BIO *bp, const RSA *r, int offset);
int RSA_sign(int type, const unsigned char *m, unsigned int m_length,
             unsigned char *sigret, unsigned int *siglen, RSA *rsa);
int RSA_verify(int type, const unsigned char *m, unsigned int m_length,
               const unsigned char *sigbuf, unsigned int siglen, RSA *rsa);
int RSA_sign_ASN1_OCTET_STRING(int type,
                               const unsigned char *m, unsigned int m_length,
                               unsigned char *sigret, unsigned int *siglen,
                               RSA *rsa);
int RSA_verify_ASN1_OCTET_STRING(int type, const unsigned char *m,
                                 unsigned int m_length, unsigned char *sigbuf,
                                 unsigned int siglen, RSA *rsa);
int RSA_blinding_on(RSA *rsa, BN_CTX *ctx);
void RSA_blinding_off(RSA *rsa);
BN_BLINDING *RSA_setup_blinding(RSA *rsa, BN_CTX *ctx);
int RSA_padding_add_PKCS1_type_1(unsigned char *to, int tlen,
                                 const unsigned char *f, int fl);
int RSA_padding_check_PKCS1_type_1(unsigned char *to, int tlen,
                                   const unsigned char *f, int fl,
                                   int rsa_len);
int RSA_padding_add_PKCS1_type_2(unsigned char *to, int tlen,
                                 const unsigned char *f, int fl);
int RSA_padding_check_PKCS1_type_2(unsigned char *to, int tlen,
                                   const unsigned char *f, int fl,
                                   int rsa_len);
int PKCS1_MGF1(unsigned char *mask, long len, const unsigned char *seed,
               long seedlen, const EVP_MD *dgst);
int RSA_padding_add_PKCS1_OAEP(unsigned char *to, int tlen,
                               const unsigned char *f, int fl,
                               const unsigned char *p, int pl);
int RSA_padding_check_PKCS1_OAEP(unsigned char *to, int tlen,
                                 const unsigned char *f, int fl, int rsa_len,
                                 const unsigned char *p, int pl);
int RSA_padding_add_PKCS1_OAEP_mgf1(unsigned char *to, int tlen,
                                    const unsigned char *from, int flen,
                                    const unsigned char *param, int plen,
                                    const EVP_MD *md, const EVP_MD *mgf1md);
int RSA_padding_check_PKCS1_OAEP_mgf1(unsigned char *to, int tlen,
                                      const unsigned char *from, int flen,
                                      int num, const unsigned char *param,
                                      int plen, const EVP_MD *md,
                                      const EVP_MD *mgf1md);
int RSA_padding_add_SSLv23(unsigned char *to, int tlen,
                           const unsigned char *f, int fl);
int RSA_padding_check_SSLv23(unsigned char *to, int tlen,
                             const unsigned char *f, int fl, int rsa_len);
int RSA_padding_add_none(unsigned char *to, int tlen, const unsigned char *f,
                         int fl);
int RSA_padding_check_none(unsigned char *to, int tlen,
                           const unsigned char *f, int fl, int rsa_len);
int RSA_padding_add_X931(unsigned char *to, int tlen, const unsigned char *f,
                         int fl);
int RSA_padding_check_X931(unsigned char *to, int tlen,
                           const unsigned char *f, int fl, int rsa_len);
int RSA_X931_hash_id(int nid);
int RSA_verify_PKCS1_PSS(RSA *rsa, const unsigned char *mHash,
                         const EVP_MD *Hash, const unsigned char *EM,
                         int sLen);
int RSA_padding_add_PKCS1_PSS(RSA *rsa, unsigned char *EM,
                              const unsigned char *mHash, const EVP_MD *Hash,
                              int sLen);
int RSA_verify_PKCS1_PSS_mgf1(RSA *rsa, const unsigned char *mHash,
                              const EVP_MD *Hash, const EVP_MD *mgf1Hash,
                              const unsigned char *EM, int sLen);
int RSA_padding_add_PKCS1_PSS_mgf1(RSA *rsa, unsigned char *EM,
                                   const unsigned char *mHash,
                                   const EVP_MD *Hash, const EVP_MD *mgf1Hash,
                                   int sLen);
#define RSA_get_ex_new_index(l,p,newf,dupf,freef) CRYPTO_get_ex_new_index(CRYPTO_EX_INDEX_RSA, l, p, newf, dupf, freef)
int RSA_set_ex_data(RSA *r, int idx, void *arg);
void *RSA_get_ex_data(const RSA *r, int idx);
RSA *RSAPublicKey_dup(RSA *rsa);
RSA *RSAPrivateKey_dup(RSA *rsa);
enum {
	RSA_FLAG_FIPS_METHOD = 0x0400,
	RSA_FLAG_NON_FIPS_ALLOW = 0x0400,
	RSA_FLAG_CHECKED     = 0x0800,
};
RSA_METHOD *RSA_meth_new(const char *name, int flags);
void RSA_meth_free(RSA_METHOD *meth);
RSA_METHOD *RSA_meth_dup(const RSA_METHOD *meth);
const char *RSA_meth_get0_name(const RSA_METHOD *meth);
int RSA_meth_set1_name(RSA_METHOD *meth, const char *name);
int RSA_meth_get_flags(const RSA_METHOD *meth);
int RSA_meth_set_flags(RSA_METHOD *meth, int flags);
void *RSA_meth_get0_app_data(const RSA_METHOD *meth);
int RSA_meth_set0_app_data(RSA_METHOD *meth, void *app_data);
int (*RSA_meth_get_pub_enc(const RSA_METHOD *meth))
    (int flen, const unsigned char *from,
     unsigned char *to, RSA *rsa, int padding);
int RSA_meth_set_pub_enc(RSA_METHOD *rsa,
                         int (*pub_enc) (int flen, const unsigned char *from,
                                         unsigned char *to, RSA *rsa,
                                         int padding));
int (*RSA_meth_get_pub_dec(const RSA_METHOD *meth))
    (int flen, const unsigned char *from,
     unsigned char *to, RSA *rsa, int padding);
int RSA_meth_set_pub_dec(RSA_METHOD *rsa,
                         int (*pub_dec) (int flen, const unsigned char *from,
                                         unsigned char *to, RSA *rsa,
                                         int padding));
int (*RSA_meth_get_priv_enc(const RSA_METHOD *meth))
    (int flen, const unsigned char *from,
     unsigned char *to, RSA *rsa, int padding);
int RSA_meth_set_priv_enc(RSA_METHOD *rsa,
                          int (*priv_enc) (int flen, const unsigned char *from,
                                           unsigned char *to, RSA *rsa,
                                           int padding));
int (*RSA_meth_get_priv_dec(const RSA_METHOD *meth))
    (int flen, const unsigned char *from,
     unsigned char *to, RSA *rsa, int padding);
int RSA_meth_set_priv_dec(RSA_METHOD *rsa,
                          int (*priv_dec) (int flen, const unsigned char *from,
                                           unsigned char *to, RSA *rsa,
                                           int padding));
int (*RSA_meth_get_mod_exp(const RSA_METHOD *meth))
    (BIGNUM *r0, const BIGNUM *i, RSA *rsa, BN_CTX *ctx);
int RSA_meth_set_mod_exp(RSA_METHOD *rsa,
                         int (*mod_exp) (BIGNUM *r0, const BIGNUM *i, RSA *rsa,
                                         BN_CTX *ctx));
int (*RSA_meth_get_bn_mod_exp(const RSA_METHOD *meth))
    (BIGNUM *r, const BIGNUM *a, const BIGNUM *p,
     const BIGNUM *m, BN_CTX *ctx, BN_MONT_CTX *m_ctx);
int RSA_meth_set_bn_mod_exp(RSA_METHOD *rsa,
                            int (*bn_mod_exp) (BIGNUM *r,
                                               const BIGNUM *a,
                                               const BIGNUM *p,
                                               const BIGNUM *m,
                                               BN_CTX *ctx,
                                               BN_MONT_CTX *m_ctx));
int (*RSA_meth_get_init(const RSA_METHOD *meth)) (RSA *rsa);
int RSA_meth_set_init(RSA_METHOD *rsa, int (*init) (RSA *rsa));
int (*RSA_meth_get_finish(const RSA_METHOD *meth)) (RSA *rsa);
int RSA_meth_set_finish(RSA_METHOD *rsa, int (*finish) (RSA *rsa));
int (*RSA_meth_get_sign(const RSA_METHOD *meth))
    (int type,
     const unsigned char *m, unsigned int m_length,
     unsigned char *sigret, unsigned int *siglen,
     const RSA *rsa);
int RSA_meth_set_sign(RSA_METHOD *rsa,
                      int (*sign) (int type, const unsigned char *m,
                                   unsigned int m_length,
                                   unsigned char *sigret, unsigned int *siglen,
                                   const RSA *rsa));
int (*RSA_meth_get_verify(const RSA_METHOD *meth))
    (int dtype, const unsigned char *m,
     unsigned int m_length, const unsigned char *sigbuf,
     unsigned int siglen, const RSA *rsa);
int RSA_meth_set_verify(RSA_METHOD *rsa,
                        int (*verify) (int dtype, const unsigned char *m,
                                       unsigned int m_length,
                                       const unsigned char *sigbuf,
                                       unsigned int siglen, const RSA *rsa));
int (*RSA_meth_get_keygen(const RSA_METHOD *meth))
    (RSA *rsa, int bits, BIGNUM *e, BN_GENCB *cb);
int RSA_meth_set_keygen(RSA_METHOD *rsa,
                        int (*keygen) (RSA *rsa, int bits, BIGNUM *e,
                                       BN_GENCB *cb));
int (*RSA_meth_get_multi_prime_keygen(const RSA_METHOD *meth))
    (RSA *rsa, int bits, int primes, BIGNUM *e, BN_GENCB *cb);
int RSA_meth_set_multi_prime_keygen(RSA_METHOD *meth,
                                    int (*keygen) (RSA *rsa, int bits,
                                                   int primes, BIGNUM *e,
                                                   BN_GENCB *cb));

																	// csrc/openssl/src/include/openssl/rsaerr.h
int ERR_load_RSA_strings(void);
enum {
	RSA_F_CHECK_PADDING_MD = 140,
	RSA_F_ENCODE_PKCS1   = 146,
	RSA_F_INT_RSA_VERIFY = 145,
	RSA_F_OLD_RSA_PRIV_DECODE = 147,
	RSA_F_PKEY_PSS_INIT  = 165,
	RSA_F_PKEY_RSA_CTRL  = 143,
	RSA_F_PKEY_RSA_CTRL_STR = 144,
	RSA_F_PKEY_RSA_SIGN  = 142,
	RSA_F_PKEY_RSA_VERIFY = 149,
	RSA_F_PKEY_RSA_VERIFYRECOVER = 141,
	RSA_F_RSA_ALGOR_TO_MD = 156,
	RSA_F_RSA_BUILTIN_KEYGEN = 129,
	RSA_F_RSA_CHECK_KEY  = 123,
	RSA_F_RSA_CHECK_KEY_EX = 160,
	RSA_F_RSA_CMS_DECRYPT = 159,
	RSA_F_RSA_CMS_VERIFY = 158,
	RSA_F_RSA_ITEM_VERIFY = 148,
	RSA_F_RSA_METH_DUP   = 161,
	RSA_F_RSA_METH_NEW   = 162,
	RSA_F_RSA_METH_SET1_NAME = 163,
	RSA_F_RSA_MGF1_TO_MD = 157,
	RSA_F_RSA_MULTIP_INFO_NEW = 166,
	RSA_F_RSA_NEW_METHOD = 106,
	RSA_F_RSA_NULL       = 124,
	RSA_F_RSA_NULL_PRIVATE_DECRYPT = 132,
	RSA_F_RSA_NULL_PRIVATE_ENCRYPT = 133,
	RSA_F_RSA_NULL_PUBLIC_DECRYPT = 134,
	RSA_F_RSA_NULL_PUBLIC_ENCRYPT = 135,
	RSA_F_RSA_OSSL_PRIVATE_DECRYPT = 101,
	RSA_F_RSA_OSSL_PRIVATE_ENCRYPT = 102,
	RSA_F_RSA_OSSL_PUBLIC_DECRYPT = 103,
	RSA_F_RSA_OSSL_PUBLIC_ENCRYPT = 104,
	RSA_F_RSA_PADDING_ADD_NONE = 107,
	RSA_F_RSA_PADDING_ADD_PKCS1_OAEP = 121,
	RSA_F_RSA_PADDING_ADD_PKCS1_OAEP_MGF1 = 154,
	RSA_F_RSA_PADDING_ADD_PKCS1_PSS = 125,
	RSA_F_RSA_PADDING_ADD_PKCS1_PSS_MGF1 = 152,
	RSA_F_RSA_PADDING_ADD_PKCS1_TYPE_1 = 108,
	RSA_F_RSA_PADDING_ADD_PKCS1_TYPE_2 = 109,
	RSA_F_RSA_PADDING_ADD_SSLV23 = 110,
	RSA_F_RSA_PADDING_ADD_X931 = 127,
	RSA_F_RSA_PADDING_CHECK_NONE = 111,
	RSA_F_RSA_PADDING_CHECK_PKCS1_OAEP = 122,
	RSA_F_RSA_PADDING_CHECK_PKCS1_OAEP_MGF1 = 153,
	RSA_F_RSA_PADDING_CHECK_PKCS1_TYPE_1 = 112,
	RSA_F_RSA_PADDING_CHECK_PKCS1_TYPE_2 = 113,
	RSA_F_RSA_PADDING_CHECK_SSLV23 = 114,
	RSA_F_RSA_PADDING_CHECK_X931 = 128,
	RSA_F_RSA_PARAM_DECODE = 164,
	RSA_F_RSA_PRINT      = 115,
	RSA_F_RSA_PRINT_FP   = 116,
	RSA_F_RSA_PRIV_DECODE = 150,
	RSA_F_RSA_PRIV_ENCODE = 138,
	RSA_F_RSA_PSS_GET_PARAM = 151,
	RSA_F_RSA_PSS_TO_CTX = 155,
	RSA_F_RSA_PUB_DECODE = 139,
	RSA_F_RSA_SETUP_BLINDING = 136,
	RSA_F_RSA_SIGN       = 117,
	RSA_F_RSA_SIGN_ASN1_OCTET_STRING = 118,
	RSA_F_RSA_VERIFY     = 119,
	RSA_F_RSA_VERIFY_ASN1_OCTET_STRING = 120,
	RSA_F_RSA_VERIFY_PKCS1_PSS_MGF1 = 126,
	RSA_F_SETUP_TBUF     = 167,
	RSA_R_ALGORITHM_MISMATCH = 100,
	RSA_R_BAD_E_VALUE    = 101,
	RSA_R_BAD_FIXED_HEADER_DECRYPT = 102,
	RSA_R_BAD_PAD_BYTE_COUNT = 103,
	RSA_R_BAD_SIGNATURE  = 104,
	RSA_R_BLOCK_TYPE_IS_NOT_01 = 106,
	RSA_R_BLOCK_TYPE_IS_NOT_02 = 107,
	RSA_R_DATA_GREATER_THAN_MOD_LEN = 108,
	RSA_R_DATA_TOO_LARGE = 109,
	RSA_R_DATA_TOO_LARGE_FOR_KEY_SIZE = 110,
	RSA_R_DATA_TOO_LARGE_FOR_MODULUS = 132,
	RSA_R_DATA_TOO_SMALL = 111,
	RSA_R_DATA_TOO_SMALL_FOR_KEY_SIZE = 122,
	RSA_R_DIGEST_DOES_NOT_MATCH = 158,
	RSA_R_DIGEST_NOT_ALLOWED = 145,
	RSA_R_DIGEST_TOO_BIG_FOR_RSA_KEY = 112,
	RSA_R_DMP1_NOT_CONGRUENT_TO_D = 124,
	RSA_R_DMQ1_NOT_CONGRUENT_TO_D = 125,
	RSA_R_D_E_NOT_CONGRUENT_TO_1 = 123,
	RSA_R_FIRST_OCTET_INVALID = 133,
	RSA_R_ILLEGAL_OR_UNSUPPORTED_PADDING_MODE = 144,
	RSA_R_INVALID_DIGEST = 157,
	RSA_R_INVALID_DIGEST_LENGTH = 143,
	RSA_R_INVALID_HEADER = 137,
	RSA_R_INVALID_LABEL  = 160,
	RSA_R_INVALID_MESSAGE_LENGTH = 131,
	RSA_R_INVALID_MGF1_MD = 156,
	RSA_R_INVALID_MULTI_PRIME_KEY = 167,
	RSA_R_INVALID_OAEP_PARAMETERS = 161,
	RSA_R_INVALID_PADDING = 138,
	RSA_R_INVALID_PADDING_MODE = 141,
	RSA_R_INVALID_PSS_PARAMETERS = 149,
	RSA_R_INVALID_PSS_SALTLEN = 146,
	RSA_R_INVALID_SALT_LENGTH = 150,
	RSA_R_INVALID_TRAILER = 139,
	RSA_R_INVALID_X931_DIGEST = 142,
	RSA_R_IQMP_NOT_INVERSE_OF_Q = 126,
	RSA_R_KEY_PRIME_NUM_INVALID = 165,
	RSA_R_KEY_SIZE_TOO_SMALL = 120,
	RSA_R_LAST_OCTET_INVALID = 134,
	RSA_R_MISSING_PRIVATE_KEY = 179,
	RSA_R_MGF1_DIGEST_NOT_ALLOWED = 152,
	RSA_R_MODULUS_TOO_LARGE = 105,
	RSA_R_MP_COEFFICIENT_NOT_INVERSE_OF_R = 168,
	RSA_R_MP_EXPONENT_NOT_CONGRUENT_TO_D = 169,
	RSA_R_MP_R_NOT_PRIME = 170,
	RSA_R_NO_PUBLIC_EXPONENT = 140,
	RSA_R_NULL_BEFORE_BLOCK_MISSING = 113,
	RSA_R_N_DOES_NOT_EQUAL_PRODUCT_OF_PRIMES = 172,
	RSA_R_N_DOES_NOT_EQUAL_P_Q = 127,
	RSA_R_OAEP_DECODING_ERROR = 121,
	RSA_R_OPERATION_NOT_SUPPORTED_FOR_THIS_KEYTYPE = 148,
	RSA_R_PADDING_CHECK_FAILED = 114,
	RSA_R_PKCS_DECODING_ERROR = 159,
	RSA_R_PSS_SALTLEN_TOO_SMALL = 164,
	RSA_R_P_NOT_PRIME    = 128,
	RSA_R_Q_NOT_PRIME    = 129,
	RSA_R_RSA_OPERATIONS_NOT_SUPPORTED = 130,
	RSA_R_SLEN_CHECK_FAILED = 136,
	RSA_R_SLEN_RECOVERY_FAILED = 135,
	RSA_R_SSLV3_ROLLBACK_ATTACK = 115,
	RSA_R_THE_ASN1_OBJECT_IDENTIFIER_IS_NOT_KNOWN_FOR_THIS_MD = 116,
	RSA_R_UNKNOWN_ALGORITHM_TYPE = 117,
	RSA_R_UNKNOWN_DIGEST = 166,
	RSA_R_UNKNOWN_MASK_DIGEST = 151,
	RSA_R_UNKNOWN_PADDING_TYPE = 118,
	RSA_R_UNSUPPORTED_ENCRYPTION_TYPE = 162,
	RSA_R_UNSUPPORTED_LABEL_SOURCE = 163,
	RSA_R_UNSUPPORTED_MASK_ALGORITHM = 153,
	RSA_R_UNSUPPORTED_MASK_PARAMETER = 154,
	RSA_R_UNSUPPORTED_SIGNATURE_TYPE = 155,
	RSA_R_VALUE_MISSING  = 147,
	RSA_R_WRONG_SIGNATURE_LENGTH = 119,
};
]]
