sub vcl_deliver {
    if(resp.http.Client-Expire) {
        call client_expire;
    }
}

C{
#include <stdlib.h>
#include <time.h>
#include <string.h>
}C
sub client_expire {
    if(resp.http.Client-Expire ~ "^[0-9]+$") {
        set resp.http.Cache-Control = "max-age=" + resp.http.Client-Expire;
        set resp.http.Age = "0";
C{
    char expire_h[30];
    time_t expire_user = atoi(VRT_GetHdr(sp, HDR_RESP, "\016Client-Expire:"));
    time_t then = time(NULL) + expire_user;
    if((strftime(expire_h, sizeof(expire_h), "%a, %d %b %Y %H:%M:%S GMT", gmtime(&then))) > 0)
        VRT_SetHdr(sp, HDR_RESP, "\010Expires:", expire_h, vrt_magic_string_end);
}C
        unset resp.http.Client-Expire;
    }
}
