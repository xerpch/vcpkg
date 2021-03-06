
include(vcpkg_common_functions)
set(GTK_VERSION 3.22.14)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/gtk+-${GTK_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/gnome/sources/gtk+/3.22/gtk+-${GTK_VERSION}.tar.xz"
    FILENAME "gtk+-${GTK_VERSION}.tar.xz"
    SHA512 f7b2cfc63f8c849c45dc4f80c8115dcf20d0da63718eedbe133f8ac86c17488a91fecb8a0e47bb6b48f81b06ce6897540d900ab8bfbe673426dacf4f7ef74e8b)

vcpkg_extract_source_archive(${ARCHIVE})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/cmake DESTINATION ${SOURCE_PATH})

# generate sources using python script installed with glib
if(NOT EXISTS ${SOURCE_PATH}/gtk/gtkdbusgenerated.h OR NOT EXISTS ${SOURCE_PATH}/gtk/gtkdbusgenerated.c)
    vcpkg_find_acquire_program(PYTHON3)
    set(GLIB_TOOL_DIR ${CURRENT_INSTALLED_DIR}/tools/glib)

    vcpkg_execute_required_process(
        COMMAND ${PYTHON3} ${GLIB_TOOL_DIR}/gdbus-codegen --interface-prefix org.Gtk. --c-namespace _Gtk --generate-c-code gtkdbusgenerated ./gtkdbusinterfaces.xml
        WORKING_DIRECTORY ${SOURCE_PATH}/gtk
        LOGNAME source-gen)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGTK_VERSION=${GTK_VERSION}
    OPTIONS_DEBUG
        -DGTK_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/gtk)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/gtk/COPYING ${CURRENT_PACKAGES_DIR}/share/gtk/copyright)
