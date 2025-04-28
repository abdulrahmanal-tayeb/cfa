#!/bin/bash

if [[ -z "$VALIDATORS_SH_SOURCED" ]]; then
    export VALIDATORS_SH_SOURCED=true;

    is_reserved(){ 
        local reserved=(assert break case catch class const continue default do else enum \
            extends false final finally for if in is new null rethrow return super \
            switch this throw true try var void while with abstract as covariant \
            deferred dynamic export external factory get implements import interface \
            library mixin operator part set static typedef)

        for w in "${reserved[@]}"; do [[ "$w" == "$1" ]] && return 0; done; return 1; 
    }
fi