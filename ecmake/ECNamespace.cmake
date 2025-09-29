include_guard(GLOBAL)

# Starts a namespace.
# NAME: The name of the new namespace
function(ec_namespace NAME)
    ec_assert("${NAME} is not a valid namespace name!"
        NAME MATCHES "[a-zA-Z][a-zA-Z0-9]*"
    )
    string(STRIP "${NAME}" NAME)
    ec_property_push_back(EC_NAMESPACE_STACK ${NAME})
endfunction()

# Ends the current namespace.
function(ec_endnamespace)
    ec_property_pop_back(EC_NAMESPACE_STACK _list)
endfunction()

# Returns the full target name by performing a namespace lookup.
# NAME: The name of the target
# OUT_VAR: The output variable
function(ec_get_target NAME OUT_VAR)
    ec_property_get(EC_NAMESPACE_STACK _current_namespace)
    string(REPLACE "::" "-" NAME ${NAME})

    list(LENGTH _current_namespace _length)
    foreach(i RANGE 1 ${_length})
        unset(_target)
        foreach(_namespace IN LISTS _current_namespace)
            string(APPEND _target "${_namespace}-")
        endforeach()

        set(_target "${_target}${NAME}")
        if (TARGET ${_target})
            set(${OUT_VAR} ${_target} PARENT_SCOPE)
            return()
        endif()
        list(POP_BACK _current_namespace)
    endforeach()

    ec_assert("Target ${NAME} does not exist!"
        FALSE
    )
endfunction(ec_get_target)


# Returns the current namespace.
# OUT_VAR: The output variable
# SEPARATOR: The namespace separator to use (usually "::")
function(ec_namespace_get OUT_VAR SEPARATOR)
    ec_property_get(EC_NAMESPACE_STACK _current_namespace)
    set(_alias_name)

    foreach(_namespace IN LISTS _current_namespace)
        string(APPEND _alias_name "${_namespace}${SEPARATOR}")
    endforeach()

    set(${OUT_VAR} "${_alias_name}" PARENT_SCOPE)
endfunction()