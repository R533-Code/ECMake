include_guard(GLOBAL)

# Parses arguments (similar to `cmake_parse_arguments`) but with default value
# support.
# PREFIX: The prefix for the output arguments
# DEFAULTS: A list of KEY;DEFAULT value (where KEY exists in ONE_VALUE or MULTI_VALUE)
#
# OPTIONS: The options (same as for `cmake_parse_arguments`)
# ONE_VALUE: The single value options (same as for `cmake_parse_arguments`)
# MULTI_VALUE: The multi-value options (same as for `cmake_parse_arguments`)
function(ec_parse_with_defaults PREFIX DEFAULTS OPTIONS ONE_VALUE MULTI_VALUE)
    set(_DEFAULTS ${DEFAULTS})
    list(LENGTH _DEFAULTS _len)

    if(_len GREATER 0)
        math(EXPR _last "${_len}-1")

        foreach(i RANGE 0 ${_last} 2)
            list(GET _DEFAULTS ${i} _k)
            math(EXPR _j "${i}+1")

            if(_j GREATER _last)
                message(FATAL_ERROR "Defaults must be KEY;VALUE pairs. Missing value for '${_k}'.")
            endif()

            list(GET _DEFAULTS ${_j} _v)
            set(_def_${_k} "${_v}")
        endforeach()
    endif()

    set(_DEFAULT_KEYS)
    list(LENGTH _DEFAULTS _len)

    if(_len GREATER 0)
        math(EXPR _last "${_len}-1")

        foreach(i RANGE 0 ${_last} 2)
            list(GET _DEFAULTS ${i} _k)
            math(EXPR _j "${i}+1")

            if(_j GREATER _last)
                message(FATAL_ERROR "Defaults must be KEY;VALUE pairs. Missing value for '${_k}'.")
            endif()

            list(GET _DEFAULTS ${_j} _v)
            set(_def_${_k} "${_v}")
            list(APPEND _DEFAULT_KEYS "${_k}")
        endforeach()
    endif()

    set(_VALUE_KEYS ${ONE_VALUE} ${MULTI_VALUE})

    foreach(_k IN LISTS _DEFAULT_KEYS)
        list(FIND _VALUE_KEYS "${_k}" _hit)

        if(_hit EQUAL -1)
            list(FIND OPTIONS "${_k}" _is_opt)

            if(_is_opt GREATER -1)
                message(FATAL_ERROR "Default provided for OPTION '${_k}'. Options are boolean and cannot have defaults.")
            else()
                message(FATAL_ERROR
                    "Default provided for undeclared key '${_k}'. Add it to ONE_VALUE or MULTI_VALUE, or remove the default.")
            endif()
        endif()
    endforeach()

    cmake_parse_arguments(PARSE "${OPTIONS}" "${ONE_VALUE}" "${MULTI_VALUE}" ${ARGN})

    foreach(k IN LISTS ONE_VALUE)
        if(DEFINED PARSE_${k})
        elseif(DEFINED _def_${k})
            set(PARSE_${k} "${_def_${k}}")
        else()
            message(FATAL_ERROR "Missing required argument '${k}' with no default.")
        endif()
    endforeach()

    foreach(k IN LISTS MULTI_VALUE)
        if(DEFINED PARSE_${k})
        elseif(DEFINED _def_${k})
            set(PARSE_${k} "${_def_${k}}")
        else()
            message(FATAL_ERROR "Missing required list '${k}' with no default.")
        endif()
    endforeach()

    foreach(k IN LISTS OPTIONS ONE_VALUE MULTI_VALUE)
        set(${PREFIX}_${k} "${PARSE_${k}}" PARENT_SCOPE)
    endforeach()
endfunction()
