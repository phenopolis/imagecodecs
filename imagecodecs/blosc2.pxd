# imagecodecs/blosc2.pxd
# cython: language_level = 3

# Cython declarations for the `c-blosc2 2.6.1` library.
# https://github.com/Blosc/c-blosc2

from libc.stdint cimport (
    int8_t, uint8_t, int16_t, uint16_t, int32_t, uint32_t, int64_t
)

ctypedef bint bool

cdef extern from 'blosc2.h':

    int  BLOSC2_VERSION_MAJOR
    int  BLOSC2_VERSION_MINOR
    int  BLOSC2_VERSION_RELEASE

    char* BLOSC2_VERSION_STRING
    char* BLOSC2_VERSION_DATE

    int BLOSC2_MAX_DIM

    int BLOSC1_VERSION_FORMAT_PRE1
    int BLOSC1_VERSION_FORMAT
    int BLOSC2_VERSION_FORMAT_ALPHA
    int BLOSC2_VERSION_FORMAT_BETA1
    int BLOSC2_VERSION_FORMAT_STABLE
    int BLOSC2_VERSION_FORMAT

    int BLOSC2_VERSION_FRAME_FORMAT_BETA2
    int BLOSC2_VERSION_FRAME_FORMAT_RC1
    int BLOSC2_VERSION_FRAME_FORMAT

    ctypedef struct blosc2_instr:
        float cratio
        float cspeed
        float filter_speed
        # float memory
        # float power
        uint8_t flags[4]

    int BLOSC_MIN_HEADER_LENGTH
    int BLOSC_EXTENDED_HEADER_LENGTH
    int BLOSC2_MAX_OVERHEAD
    int BLOSC2_MAX_BUFFERSIZE
    int BLOSC_MAX_TYPESIZE
    int BLOSC_MIN_BUFFERSIZE

    int BLOSC2_DEFINED_FILTERS_START
    int BLOSC2_DEFINED_FILTERS_STOP
    int BLOSC2_GLOBAL_REGISTERED_FILTERS_START
    int BLOSC2_GLOBAL_REGISTERED_FILTERS_STOP
    int BLOSC2_GLOBAL_REGISTERED_FILTERS
    int BLOSC2_USER_REGISTERED_FILTERS_START
    int BLOSC2_USER_REGISTERED_FILTERS_STOP
    int BLOSC2_MAX_FILTERS
    int BLOSC2_MAX_UDFILTERS

    int BLOSC_NOSHUFFLE
    int BLOSC_NOFILTER
    int BLOSC_SHUFFLE
    int BLOSC_BITSHUFFLE
    int BLOSC_DELTA
    int BLOSC_TRUNC_PREC
    int BLOSC_LAST_FILTER
    int BLOSC_LAST_REGISTERED_FILTER

    int BLOSC_DOSHUFFLE
    int BLOSC_MEMCPYED
    int BLOSC_DOBITSHUFFLE
    int BLOSC_DODELTA

    int BLOSC2_USEDICT
    int BLOSC2_BIGENDIAN
    int BLOSC2_INSTR_CODEC

    int BLOSC2_MAXDICTSIZE
    int BLOSC2_MAXBLOCKSIZE

    int BLOSC2_DEFINED_CODECS_START
    int BLOSC2_DEFINED_CODECS_STOP
    int BLOSC2_GLOBAL_REGISTERED_CODECS_START
    int BLOSC2_GLOBAL_REGISTERED_CODECS_STOP
    int BLOSC2_GLOBAL_REGISTERED_CODECS
    int BLOSC2_USER_REGISTERED_CODECS_START
    int BLOSC2_USER_REGISTERED_CODECS_STOP

    int BLOSC_BLOSCLZ
    int BLOSC_LZ4
    int BLOSC_LZ4HC
    int BLOSC_ZLIB
    int BLOSC_ZSTD
    int BLOSC_LAST_CODEC
    int BLOSC_LAST_REGISTERED_CODEC

    char* BLOSC_BLOSCLZ_COMPNAME
    char* BLOSC_LZ4_COMPNAME
    char* BLOSC_LZ4HC_COMPNAME
    char* BLOSC_ZLIB_COMPNAME
    char* BLOSC_ZSTD_COMPNAME

    int BLOSC_BLOSCLZ_LIB
    int BLOSC_LZ4_LIB
    int BLOSC_ZLIB_LIB
    int BLOSC_ZSTD_LIB
    int BLOSC_UDCODEC_LIB
    int BLOSC_SCHUNK_LIB

    char* BLOSC_BLOSCLZ_LIBNAME
    char* BLOSC_LZ4_LIBNAME
    char* BLOSC_ZLIB_LIBNAME
    char* BLOSC_ZSTD_LIBNAME

    int BLOSC_BLOSCLZ_FORMAT
    int BLOSC_LZ4_FORMAT
    int BLOSC_LZ4HC_FORMAT
    int BLOSC_ZLIB_FORMAT
    int BLOSC_ZSTD_FORMAT
    int BLOSC_UDCODEC_FORMAT

    int BLOSC_BLOSCLZ_VERSION_FORMAT
    int BLOSC_LZ4_VERSION_FORMAT
    int BLOSC_LZ4HC_VERSION_FORMAT
    int BLOSC_ZLIB_VERSION_FORMAT
    int BLOSC_ZSTD_VERSION_FORMAT
    int BLOSC_UDCODEC_VERSION_FORMAT

    int BLOSC_ALWAYS_SPLIT
    int BLOSC_NEVER_SPLIT
    int BLOSC_AUTO_SPLIT
    int BLOSC_FORWARD_COMPAT_SPLIT

    int BLOSC2_CHUNK_VERSION
    int BLOSC2_CHUNK_VERSIONLZ
    int BLOSC2_CHUNK_FLAGS
    int BLOSC2_CHUNK_TYPESIZE
    int BLOSC2_CHUNK_NBYTES
    int BLOSC2_CHUNK_BLOCKSIZE
    int BLOSC2_CHUNK_CBYTES
    int BLOSC2_CHUNK_FILTER_CODES
    int BLOSC2_CHUNK_FILTER_META
    int BLOSC2_CHUNK_BLOSC2_FLAGS

    int BLOSC2_NO_SPECIAL
    int BLOSC2_SPECIAL_ZERO
    int BLOSC2_SPECIAL_NAN
    int BLOSC2_SPECIAL_VALUE
    int BLOSC2_SPECIAL_UNINIT
    int BLOSC2_SPECIAL_LASTID
    int BLOSC2_SPECIAL_MASK

    int BLOSC2_ERROR_SUCCESS
    int BLOSC2_ERROR_FAILURE
    int BLOSC2_ERROR_STREAM
    int BLOSC2_ERROR_DATA
    int BLOSC2_ERROR_MEMORY_ALLOC
    int BLOSC2_ERROR_READ_BUFFER
    int BLOSC2_ERROR_WRITE_BUFFER
    int BLOSC2_ERROR_CODEC_SUPPORT
    int BLOSC2_ERROR_CODEC_PARAM
    int BLOSC2_ERROR_CODEC_DICT
    int BLOSC2_ERROR_VERSION_SUPPORT
    int BLOSC2_ERROR_INVALID_HEADER
    int BLOSC2_ERROR_INVALID_PARAM
    int BLOSC2_ERROR_FILE_READ
    int BLOSC2_ERROR_FILE_WRITE
    int BLOSC2_ERROR_FILE_OPEN
    int BLOSC2_ERROR_NOT_FOUND
    int BLOSC2_ERROR_RUN_LENGTH
    int BLOSC2_ERROR_FILTER_PIPELINE
    int BLOSC2_ERROR_CHUNK_INSERT
    int BLOSC2_ERROR_CHUNK_APPEND
    int BLOSC2_ERROR_CHUNK_UPDATE
    int BLOSC2_ERROR_2GB_LIMIT
    int BLOSC2_ERROR_SCHUNK_COPY
    int BLOSC2_ERROR_FRAME_TYPE
    int BLOSC2_ERROR_FILE_TRUNCATE
    int BLOSC2_ERROR_THREAD_CREATE
    int BLOSC2_ERROR_POSTFILTER
    int BLOSC2_ERROR_FRAME_SPECIAL
    int BLOSC2_ERROR_SCHUNK_SPECIAL
    int BLOSC2_ERROR_PLUGIN_IO
    int BLOSC2_ERROR_FILE_REMOVE

    void blosc2_init() nogil

    void blosc2_destroy() nogil

    int blosc1_compress(
        int clevel,
        int doshuffle,
        size_t typesize,
        size_t nbytes,
        const void* src,
        void* dest,
        size_t destsize
    ) nogil

    int blosc1_decompress(
        const void* src,
        void* dest,
        size_t destsize
    ) nogil

    int blosc1_getitem(
        const void* src,
        int start,
        int nitems,
        void* dest
    ) nogil

    int blosc2_getitem(
        const void* src,
        int32_t srcsize,
        int start,
        int nitems,
        void* dest,
        int32_t destsize
    ) nogil

    ctypedef void (*blosc_threads_callback)(
        void* callback_data,
        void (*dojob)(void*),
        int numjobs,
        size_t jobdata_elsize,
        void* jobdata
    ) nogil

    void blosc2_set_threads_callback(
        blosc_threads_callback callback,
        void* callback_data
    ) nogil

    int16_t blosc2_get_nthreads() nogil

    int16_t blosc2_set_nthreads(
        int16_t nthreads
    ) nogil

    const char* blosc1_get_compressor() nogil

    int blosc1_set_compressor(
        const char* compname
    ) nogil

    void blosc2_set_delta(
        int dodelta
    ) nogil

    int blosc2_compcode_to_compname(
        int compcode,
        const char** compname
    ) nogil

    int blosc2_compname_to_compcode(
        const char* compname
    ) nogil

    const char* blosc2_list_compressors() nogil

    const char* blosc2_get_version_string() nogil

    int blosc2_get_complib_info(
        const char* compname,
        char** complib,
        char** version
    ) nogil

    int blosc2_free_resources() nogil

    void blosc1_cbuffer_sizes(
        const void* cbuffer,
        size_t* nbytes,
        size_t* cbytes,
        size_t* blocksize
    ) nogil

    int blosc2_cbuffer_sizes(
        const void* cbuffer,
        int32_t* nbytes,
        int32_t* cbytes,
        int32_t* blocksize
    ) nogil

    int blosc1_cbuffer_validate(
        const void* cbuffer,
        size_t cbytes,
        size_t* nbytes
    ) nogil

    void blosc1_cbuffer_metainfo(
        const void* cbuffer,
        size_t* typesize,
        int* flags
    ) nogil

    void blosc2_cbuffer_versions(
        const void* cbuffer,
        int* version,
        int* versionlz
    ) nogil

    const char* blosc2_cbuffer_complib(
        const void* cbuffer
    ) nogil

    int BLOSC2_IO_FILESYSTEM
    int BLOSC_IO_LAST_BLOSC_DEFINED
    int BLOSC_IO_LAST_REGISTERED

    int BLOSC2_IO_BLOSC_DEFINED
    int BLOSC2_IO_REGISTERED
    int BLOSC2_IO_USER_DEFINED

    ctypedef void* (*blosc2_open_cb)(
        const char* urlpath,
        const char* mode,
        void* params
    ) nogil

    ctypedef int (*blosc2_close_cb)(
        void* stream
    ) nogil

    ctypedef int64_t (*blosc2_tell_cb)(
        void* stream
    ) nogil

    ctypedef int (*blosc2_seek_cb)(
        void* stream,
        int64_t offset,
        int whence
    ) nogil

    ctypedef int64_t (*blosc2_write_cb)(
        const void* ptr,
        int64_t size,
        int64_t nitems,
        void* stream
    ) nogil

    ctypedef int64_t (*blosc2_read_cb)(
        void* ptr,
        int64_t size,
        int64_t nitems,
        void* stream
    ) nogil

    ctypedef int (*blosc2_truncate_cb)(
        void* stream,
        int64_t size
    ) nogil

    ctypedef struct blosc2_io_cb:
        uint8_t id
        blosc2_open_cb open
        blosc2_close_cb close
        blosc2_tell_cb tell
        blosc2_seek_cb seek
        blosc2_write_cb write
        blosc2_read_cb read
        blosc2_truncate_cb truncate

    ctypedef struct blosc2_io:
        uint8_t id
        void* params

    const blosc2_io_cb BLOSC2_IO_CB_DEFAULTS

    const blosc2_io BLOSC2_IO_DEFAULTS

    int blosc2_register_io_cb(
        const blosc2_io_cb* io
    ) nogil

    blosc2_io_cb* blosc2_get_io_cb(
        uint8_t id
    ) nogil

    ctypedef struct blosc2_context:
        pass

    ctypedef struct blosc2_btune:
        void (*btune_init)(
            void* config,
            blosc2_context* cctx,
            blosc2_context* dctx
        ) nogil
        void (*btune_next_blocksize)(
            blosc2_context* context
        ) nogil
        void (*btune_next_cparams)(
            blosc2_context* context
        ) nogil
        void (*btune_update)(
            blosc2_context* context,
            double ctime
        ) nogil
        void (*btune_free)(
            blosc2_context* context
        ) nogil
        void* btune_config

    ctypedef struct blosc2_prefilter_params:
        void* user_data
        const uint8_t* input
        uint8_t* output
        int32_t output_size
        int32_t output_typesize
        int32_t output_offset
        int64_t nchunk
        int32_t nblock
        int32_t tid
        uint8_t* ttmp
        size_t ttmp_nbytes
        blosc2_context* ctx

    ctypedef struct blosc2_postfilter_params:
        void* user_data
        const uint8_t* input
        uint8_t* output
        int32_t size
        int32_t typesize
        int32_t offset
        int64_t nchunk
        int32_t nblock
        int32_t tid
        uint8_t* ttmp
        size_t ttmp_nbytes
        blosc2_context* ctx

    ctypedef int (*blosc2_prefilter_fn)(
        blosc2_prefilter_params* params
    ) nogil

    ctypedef int (*blosc2_postfilter_fn)(
        blosc2_postfilter_params* params
    ) nogil

    ctypedef struct blosc2_cparams:
        uint8_t compcode
        uint8_t compcode_meta
        uint8_t clevel
        int use_dict
        int32_t typesize
        int16_t nthreads
        int32_t blocksize
        int32_t splitmode
        void* schunk
        uint8_t filters[6]  # BLOSC2_MAX_FILTERS
        uint8_t filters_meta[6]  # BLOSC2_MAX_FILTERS
        blosc2_prefilter_fn prefilter
        blosc2_prefilter_params* preparams
        blosc2_btune* udbtune
        bool instr_codec

    const blosc2_cparams BLOSC2_CPARAMS_DEFAULTS

    ctypedef struct blosc2_dparams:
        int16_t nthreads
        void* schunk
        blosc2_postfilter_fn postfilter
        blosc2_postfilter_params* postparams

    const blosc2_dparams BLOSC2_DPARAMS_DEFAULTS

    blosc2_context* blosc2_create_cctx(
        blosc2_cparams cparams
    ) nogil

    blosc2_context* blosc2_create_dctx(
        blosc2_dparams dparams
    ) nogil

    void blosc2_free_ctx(
        blosc2_context* context
    ) nogil

    int blosc2_ctx_get_cparams(
        blosc2_context* ctx,
        blosc2_cparams* cparams
    ) nogil

    int blosc2_ctx_get_dparams(
        blosc2_context* ctx,
        blosc2_dparams* dparams
    ) nogil

    int blosc2_set_maskout(
        blosc2_context* ctx,
        bool* maskout,
        int nblocks
    ) nogil

    int blosc2_compress(
        int clevel,
        int doshuffle,
        int32_t typesize,
        const void* src,
        int32_t srcsize,
        void* dest,
        int32_t destsize
    ) nogil

    int blosc2_decompress(
        const void* src,
        int32_t srcsize,
        void* dest,
        int32_t destsize
    ) nogil

    int blosc2_compress_ctx(
        blosc2_context* context,
        const void* src,
        int32_t srcsize,
        void* dest,
        int32_t destsize
    ) nogil

    int blosc2_decompress_ctx(
        blosc2_context* context,
        const void* src,
        int32_t srcsize,
        void* dest,
        int32_t destsize
    ) nogil

    int blosc2_chunk_zeros(
        blosc2_cparams cparams,
        int32_t nbytes,
        void* dest,
        int32_t destsize
    ) nogil

    int blosc2_chunk_nans(
        blosc2_cparams cparams,
        int32_t nbytes,
        void* dest,
        int32_t destsize
    ) nogil

    int blosc2_chunk_repeatval(
        blosc2_cparams cparams,
        int32_t nbytes,
        void* dest,
        int32_t destsize,
        void* repeatval
    ) nogil

    int blosc2_chunk_uninit(
        blosc2_cparams cparams,
        int32_t nbytes,
        void* dest,
        int32_t destsize
    ) nogil

    int blosc2_getitem_ctx(
        blosc2_context* context,
        const void* src,
        int32_t srcsize,
        int start,
        int nitems,
        void* dest,
        int32_t destsize
    ) nogil

    int BLOSC2_MAX_METALAYERS
    int BLOSC2_METALAYER_NAME_MAXLEN

    int BLOSC2_MAX_VLMETALAYERS
    int BLOSC2_VLMETALAYERS_NAME_MAXLEN

    ctypedef struct blosc2_storage:
        bool contiguous
        char* urlpath
        blosc2_cparams* cparams
        blosc2_dparams* dparams
        blosc2_io* io

    const blosc2_storage BLOSC2_STORAGE_DEFAULTS

    ctypedef struct blosc2_frame:
        pass

    ctypedef struct blosc2_metalayer :
        char* name
        uint8_t* content
        int32_t content_len

    ctypedef struct blosc2_schunk :
        uint8_t version
        uint8_t compcode
        uint8_t compcode_meta
        uint8_t clevel
        uint8_t splitmode
        int32_t typesize
        int32_t blocksize
        int32_t chunksize
        uint8_t filters[6]  # BLOSC2_MAX_FILTERS
        uint8_t filters_meta[6]  # BLOSC2_MAX_FILTERS
        int64_t nchunks
        int64_t current_nchunk
        int64_t nbytes
        int64_t cbytes
        uint8_t** data
        size_t data_len
        blosc2_storage* storage
        blosc2_frame* frame
        blosc2_context* cctx
        blosc2_context* dctx
        blosc2_metalayer* metalayers[16]  # BLOSC2_MAX_METALAYERS
        uint16_t nmetalayers
        blosc2_metalayer* vlmetalayers[8 * 1024]  # BLOSC2_MAX_VLMETALAYERS
        int16_t nvlmetalayers
        blosc2_btune* udbtune
        int8_t ndim
        int64_t *blockshape

    blosc2_schunk* blosc2_schunk_new(
        blosc2_storage* storage
    ) nogil

    blosc2_schunk* blosc2_schunk_copy(
        blosc2_schunk* schunk,
        blosc2_storage* storage
    ) nogil

    blosc2_schunk* blosc2_schunk_from_buffer(
        uint8_t* cframe,
        int64_t len,
        bool copy
    ) nogil

    void blosc2_schunk_avoid_cframe_free(
        blosc2_schunk *schunk,
        bool avoid_cframe_free
    ) nogil

    blosc2_schunk* blosc2_schunk_open(
        const char* urlpath
    ) nogil

    blosc2_schunk* blosc2_schunk_open_offset(
        const char* urlpath,
        int64_t offset
    ) nogil

    blosc2_schunk* blosc2_schunk_open_udio(
        const char* urlpath,
        const blosc2_io* udio
    ) nogil

    int64_t blosc2_schunk_to_buffer(
        blosc2_schunk* schunk,
        uint8_t** cframe,
        bool* needs_free
    ) nogil

    int64_t blosc2_schunk_to_file(
        blosc2_schunk* schunk,
        const char* urlpath
    ) nogil

    int64_t blosc2_schunk_append_file(
        blosc2_schunk* schunk,
        const char* urlpath
    ) nogil

    int blosc2_schunk_free(
        blosc2_schunk* schunk
    ) nogil

    int64_t blosc2_schunk_append_chunk(
        blosc2_schunk* schunk,
        uint8_t* chunk,
        bool copy
    ) nogil

    int64_t blosc2_schunk_update_chunk(
        blosc2_schunk* schunk,
        int64_t nchunk,
        uint8_t* chunk,
        bool copy
    ) nogil

    int64_t blosc2_schunk_insert_chunk(
        blosc2_schunk* schunk,
        int64_t nchunk,
        uint8_t* chunk,
        bool copy
    ) nogil

    int64_t blosc2_schunk_delete_chunk(
        blosc2_schunk* schunk,
        int64_t nchunk
    ) nogil

    int64_t blosc2_schunk_append_buffer(
        blosc2_schunk* schunk,
        void* src,
        int32_t nbytes
    ) nogil

    int blosc2_schunk_decompress_chunk(
        blosc2_schunk* schunk,
        int64_t nchunk,
        void* dest,
        int32_t nbytes
    ) nogil

    int blosc2_schunk_get_chunk(
        blosc2_schunk* schunk,
        int64_t nchunk,
        uint8_t** chunk,
        bool* needs_free
    ) nogil

    int blosc2_schunk_get_lazychunk(
        blosc2_schunk* schunk,
        int64_t nchunk,
        uint8_t** chunk,
        bool* needs_free
    ) nogil

    int blosc2_schunk_get_slice_buffer(
        blosc2_schunk *schunk,
        int64_t start,
        int64_t stop,
        void *buffer
    ) nogil

    int blosc2_schunk_set_slice_buffer(
        blosc2_schunk *schunk,
        int64_t start,
        int64_t stop,
        void *buffer
    ) nogil

    int blosc2_schunk_get_cparams(
        blosc2_schunk* schunk,
        blosc2_cparams** cparams
    ) nogil

    int blosc2_schunk_get_dparams(
        blosc2_schunk* schunk,
        blosc2_dparams** dparams
    ) nogil

    int blosc2_schunk_reorder_offsets(
        blosc2_schunk* schunk,
        int64_t* offsets_order
    ) nogil

    int64_t blosc2_schunk_frame_len(
        blosc2_schunk* schunk
    ) nogil

    int64_t blosc2_schunk_fill_special(
        blosc2_schunk* schunk,
        int64_t nitems,
        int special_value,
        int32_t chunksize
    ) nogil

    int blosc2_meta_exists(
        blosc2_schunk* schunk,
        const char* name
    ) nogil

    int blosc2_meta_add(
        blosc2_schunk* schunk,
        const char* name,
        uint8_t* content,
        int32_t content_len
    ) nogil

    int blosc2_meta_update(
        blosc2_schunk* schunk,
        const char* name,
        uint8_t* content,
        int32_t content_len
    ) nogil

    int blosc2_meta_get(
        blosc2_schunk* schunk,
        const char* name,
        uint8_t** content,
        int32_t* content_len
    ) nogil

    int blosc2_vlmeta_exists(
        blosc2_schunk* schunk,
        const char* name
    ) nogil

    int blosc2_vlmeta_add(
        blosc2_schunk* schunk,
        const char* name,
        uint8_t* content,
        int32_t content_len,
        blosc2_cparams* cparams
    ) nogil

    int blosc2_vlmeta_update(
        blosc2_schunk* schunk,
        const char* name,
        uint8_t* content,
        int32_t content_len,
        blosc2_cparams* cparams
    ) nogil

    int blosc2_vlmeta_get(
        blosc2_schunk* schunk,
        const char* name,
        uint8_t** content,
        int32_t* content_len
    ) nogil

    int blosc2_vlmeta_delete(
        blosc2_schunk *schunk,
        const char *name
    ) nogil

    int blosc2_vlmeta_get_names(
        blosc2_schunk *schunk,
        char **names
    ) nogil

    ctypedef struct blosc_timestamp_t:
        pass

    void blosc_set_timestamp(
        blosc_timestamp_t* timestamp
    ) nogil

    double blosc_elapsed_nsecs(
        blosc_timestamp_t start_time,
        blosc_timestamp_t end_time
    ) nogil

    double blosc_elapsed_secs(
        blosc_timestamp_t start_time,
        blosc_timestamp_t end_time
    ) nogil

    int blosc1_get_blocksize(
    ) nogil

    void blosc1_set_blocksize(
        size_t blocksize
    ) nogil

    void blosc1_set_splitmode(
        int splitmode
    ) nogil

    # void blosc_set_schunk(
    #     blosc2_schunk* schunk
    # ) nogil

    int64_t* blosc2_frame_get_offsets(
        blosc2_schunk *schunk
    ) nogil

    ctypedef int (*blosc2_codec_encoder_cb)(
        const uint8_t* input,
        int32_t input_len,
        uint8_t* output,
        int32_t output_len,
        uint8_t meta,
        blosc2_cparams* cparams,
        const void* chunk
    ) nogil

    ctypedef int (*blosc2_codec_decoder_cb)(
        const uint8_t* input,
        int32_t input_len,
        uint8_t* output,
        int32_t output_len,
        uint8_t meta,
        blosc2_dparams* dparams,
        const void* chunk
    ) nogil

    ctypedef struct blosc2_codec:
        uint8_t compcode
        char* compname
        uint8_t complib
        uint8_t compver
        blosc2_codec_encoder_cb encoder
        blosc2_codec_decoder_cb decoder

    int blosc2_register_codec(
        blosc2_codec* codec
    ) nogil

    ctypedef int (*blosc2_filter_forward_cb)(
        const uint8_t*,
        uint8_t*,
        int32_t,
        uint8_t,
        blosc2_cparams*
    ) nogil

    ctypedef int (*blosc2_filter_backward_cb)(
        const uint8_t*,
        uint8_t*,
        int32_t,
        uint8_t,
        blosc2_dparams*
    ) nogil

    ctypedef struct blosc2_filter:
        uint8_t id
        blosc2_filter_forward_cb forward
        blosc2_filter_backward_cb backward

    int blosc2_register_filter(
        blosc2_filter* filter
    ) nogil

    int blosc2_remove_dir(
        const char* path
    ) nogil

    int blosc2_remove_urlpath(
        const char* path
    ) nogil

    int blosc2_rename_urlpath(
        char* old_urlpath,
        char* new_path
    ) nogil

    void blosc2_unidim_to_multidim(
        uint8_t ndim,
        int64_t *shape,
        int64_t i,
        int64_t *index
    ) nogil

    void blosc2_multidim_to_unidim(
        const int64_t *index,
        int8_t ndim,
        const int64_t
        *strides,
        int64_t *i
    ) nogil
