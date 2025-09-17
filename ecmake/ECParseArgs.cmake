include_guard(GLOBAL)

# Parses arguments (similar to `cmake_parse_arguments`) but with default value
# support.
# PREFIX: The prefix for the output arguments
# DEFAULTS: A list of KEY;DEFAULT value (where KEY exists in ONE_VALUE or MULTI_VALUE)
#
# OPTIONS: The options (same as for `cmake_parse_arguments`)
# ONE_VALUE: The single value options (same as for `cmake_parse_arguments`)
# MULTI_VALUE: The multi-value options (same as for `cmake_parse_arguments`)
function(ec_parse_with_DEFAULTS PREFIX DEFAULTS OPTIONS ONE_VALUE MULTI_VALUE)
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
