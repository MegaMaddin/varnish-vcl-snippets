sub vcl_recv {
    set req.X-Debug-ID = "1ec1263ef37ff4c31edddd9e657cd96b68b9eebf";
    if (req.restarts > 0) {
            if (req.http.X-Debug-Trace) {
                set req.http.X-Debug-Trace = req.http.X-Debug-Trace + ", vcl_restart";
            } else {
                set req.http.X-Debug-Trace = "vcl_restart";
            }
    }
    if (req.http.X-Debug-Trace) {
        set req.http.X-Debug-Trace = req.http.X-Debug-Trace + ", vcl_recv";
    } else {
        set req.http.X-Debug-Trace = "vcl_recv";
    }
}

sub vcl_pipe {
    if (req.http.X-Debug-Trace) {
        set req.http.X-Debug-Trace = req.http.X-Debug-Trace + ", vcl_pipe";
    } else {
        set req.http.X-Debug-Trace = "vcl_pipe";
    }
}

sub vcl_pass {
    if (req.http.X-Debug-Trace) {
        set req.http.X-Debug-Trace = req.http.X-Debug-Trace + ", vcl_pass";
    } else {
        set req.http.X-Debug-Trace = "vcl_pass";
    }
}

sub vcl_hash {
    if (req.http.X-Debug-Trace) {
        set req.http.X-Debug-Trace = req.http.X-Debug-Trace + ", vcl_hash";
    } else {
        set req.http.X-Debug-Trace = "vcl_hash";
    }
}

sub vcl_hit {
    if (req.http.X-Debug-Trace) {
        set req.http.X-Debug-Trace = req.http.X-Debug-Trace + ", vcl_hit";
    } else {
        set req.http.X-Debug-Trace = "vcl_hit";
    }
    # save some information for later use
    set req.http.X-Lifetime = obj.ttl;
}

sub vcl_miss {
    if (req.http.X-Debug-Trace) {
        set req.http.X-Debug-Trace = req.http.X-Debug-Trace + ", vcl_miss";
    } else {
        set req.http.X-Debug-Trace = "vcl_miss";
    }
}

sub vcl_fetch {
    if (req.http.X-Debug-Trace) {
        set req.http.X-Debug-Trace = req.http.X-Debug-Trace + ", vcl_fetch";
    } else {
        set req.http.X-Debug-Trace = "vcl_fetch";
    }

    # save some information for later use
    set req.http.X-BE-Name = beresp.backend.name;
    set beresp.http.X-Purge-URL = req.url;
    set beresp.http.X-Purge-Host = req.http.host;
}

sub vcl_deliver {
    if (req.http.X-Debug-Trace) {
        set req.http.X-Debug-Trace = req.http.X-Debug-Trace + ", vcl_deliver";
    } else {
        set req.http.X-Debug-Trace = "vcl_deliver";
    }

    # if we receive a debug header, print some more debugging http-headers.
    if (req.http.X-Debug == req.http.X-Debug-ID) {
        # Append new header "X-Cache", if we deliver cached content
        if (obj.hits > 0) {
            set resp.http.X-Cache = "HIT (" + obj.hits + ")";
        } else {
            set resp.http.X-Cache = "MISS";
        }

        # Append the used backend - is a director is used, only the directors name will be appended
        set resp.http.X-BE = req.backend;
        if (req.http.X-BE-Name) {
            set resp.http.X-BE-Name = req.http.X-BE-Name;
        } else {
            set resp.http.X-BE-Name = server.identity;
        }

        # Append the objects lifetime, if fetched from cache
        if (req.http.X-Lifetime) {
            set resp.http.X-Lifetime = req.http.X-Lifetime;
        }

        set resp.http.X-Debug-Trace = req.http.X-Debug-Trace;

        # If a restart has occured, append the number of restarts
        if (req.restarts > 0) {
            set resp.http.X-Restarts = req.restarts;
        }
    } else {
    # Or delete the following headers by default
        unset resp.http.Via;
        unset resp.http.X-Varnish;
        unset resp.http.X-Purge-URL;
        unset resp.http.X-Purge-Host;
        unset resp.http.X-Debug-Trace;
    }
}

sub vcl_error {
    if (req.http.X-Debug-Trace) {
        set req.http.X-Debug-Trace = req.http.X-Debug-Trace + ", vcl_error";
    } else {
        set req.http.X-Debug-Trace = "vcl_error";
    }
}
