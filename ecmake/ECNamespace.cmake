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

function(ec_namespace_get OUT_VAR SEPARATOR)
    ec_property_get(EC_NAMESPACE_STACK _current_namespace)
    set(_alias_name)

    foreach(_namespace IN LISTS _current_namespace)
        string(APPEND _alias_name "${_namespace}${SEPARATOR}")
    endforeach()
    
    set(${OUT_VAR} "${_alias_name}" PARENT_SCOPE)
endfunction()