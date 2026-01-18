# Copyright (c) 2026 Raphael Dib Nehme
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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