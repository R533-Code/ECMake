include_guard(GLOBAL)

function(ec_parse_with_defaults prefix defaults options one_value multi_value)
    set(_defaults ${defaults})
    list(LENGTH _defaults _len)

    if(_len GREATER 0)
        math(EXPR _last "${_len}-1")

        foreach(i RANGE 0 ${_last} 2)
            list(GET _defaults ${i} _k)
            math(EXPR _j "${i}+1")

            if(_j GREATER _last)
                message(FATAL_ERROR "Defaults must be KEY;VALUE pairs. Missing value for '${_k}'.")
            endif()

            list(GET _defaults ${_j} _v)
            set(_def_${_k} "${_v}")
        endforeach()
    endif()

    cmake_parse_arguments(PARSE "${options}" "${one_value}" "${multi_value}" ${ARGN})

    foreach(k IN LISTS one_value)
        if(DEFINED PARSE_${k})
        elseif(DEFINED _def_${k})
            set(PARSE_${k} "${_def_${k}}")
        else()
            message(FATAL_ERROR "Missing required argument '${k}' with no default.")
        endif()
    endforeach()

    foreach(k IN LISTS multi_value)
        if(DEFINED PARSE_${k})
        elseif(DEFINED _def_${k})
            set(PARSE_${k} "${_def_${k}}")
        else()
            message(FATAL_ERROR "Missing required list '${k}' with no default.")
        endif()
    endforeach()

    foreach(k IN LISTS options one_value multi_value)
        set(${prefix}_${k} "${PARSE_${k}}" PARENT_SCOPE)
    endforeach()
endfunction()
