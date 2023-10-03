# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/heap
    REF boost-1.81.0
    SHA512 b78fa8f5ac869af94e6b2917d7d2e60cb717131a6fe825bdc335edd11cc37b0b38af8d7b87fd48662d5748263f1efe6a7185fd136cb7b149a17973ddf030d55c
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
