#ifndef DYLIBLOAD_WRAPPER_LIBDECOR
#define DYLIBLOAD_WRAPPER_LIBDECOR
// This file is generated. Do not edit!
// see https://github.com/hpvb/dynload-wrapper for details
// generated by ./generate-wrapper.py 0.3 on 2022-12-12 10:55:19
// flags: ./generate-wrapper.py --include /usr/include/libdecor-0/libdecor.h --sys-include <libdecor-0/libdecor.h> --soname libdecor-0.so.0 --init-name libdecor --output-header libdecor-so_wrap.h --output-implementation libdecor-so_wrap.c --omit-prefix wl_
//
// EDIT: This has been handpatched to properly report the pointer type of the window_state argument of libdecor_configuration_get_window_state.
#include <stdint.h>

#define libdecor_unref libdecor_unref_dylibloader_orig_libdecor
#define libdecor_new libdecor_new_dylibloader_orig_libdecor
#define libdecor_get_fd libdecor_get_fd_dylibloader_orig_libdecor
#define libdecor_dispatch libdecor_dispatch_dylibloader_orig_libdecor
#define libdecor_decorate libdecor_decorate_dylibloader_orig_libdecor
#define libdecor_frame_ref libdecor_frame_ref_dylibloader_orig_libdecor
#define libdecor_frame_unref libdecor_frame_unref_dylibloader_orig_libdecor
#define libdecor_frame_set_visibility libdecor_frame_set_visibility_dylibloader_orig_libdecor
#define libdecor_frame_is_visible libdecor_frame_is_visible_dylibloader_orig_libdecor
#define libdecor_frame_set_parent libdecor_frame_set_parent_dylibloader_orig_libdecor
#define libdecor_frame_set_title libdecor_frame_set_title_dylibloader_orig_libdecor
#define libdecor_frame_get_title libdecor_frame_get_title_dylibloader_orig_libdecor
#define libdecor_frame_set_app_id libdecor_frame_set_app_id_dylibloader_orig_libdecor
#define libdecor_frame_set_capabilities libdecor_frame_set_capabilities_dylibloader_orig_libdecor
#define libdecor_frame_unset_capabilities libdecor_frame_unset_capabilities_dylibloader_orig_libdecor
#define libdecor_frame_has_capability libdecor_frame_has_capability_dylibloader_orig_libdecor
#define libdecor_frame_show_window_menu libdecor_frame_show_window_menu_dylibloader_orig_libdecor
#define libdecor_frame_popup_grab libdecor_frame_popup_grab_dylibloader_orig_libdecor
#define libdecor_frame_popup_ungrab libdecor_frame_popup_ungrab_dylibloader_orig_libdecor
#define libdecor_frame_translate_coordinate libdecor_frame_translate_coordinate_dylibloader_orig_libdecor
#define libdecor_frame_set_min_content_size libdecor_frame_set_min_content_size_dylibloader_orig_libdecor
#define libdecor_frame_set_max_content_size libdecor_frame_set_max_content_size_dylibloader_orig_libdecor
#define libdecor_frame_resize libdecor_frame_resize_dylibloader_orig_libdecor
#define libdecor_frame_move libdecor_frame_move_dylibloader_orig_libdecor
#define libdecor_frame_commit libdecor_frame_commit_dylibloader_orig_libdecor
#define libdecor_frame_set_minimized libdecor_frame_set_minimized_dylibloader_orig_libdecor
#define libdecor_frame_set_maximized libdecor_frame_set_maximized_dylibloader_orig_libdecor
#define libdecor_frame_unset_maximized libdecor_frame_unset_maximized_dylibloader_orig_libdecor
#define libdecor_frame_set_fullscreen libdecor_frame_set_fullscreen_dylibloader_orig_libdecor
#define libdecor_frame_unset_fullscreen libdecor_frame_unset_fullscreen_dylibloader_orig_libdecor
#define libdecor_frame_is_floating libdecor_frame_is_floating_dylibloader_orig_libdecor
#define libdecor_frame_close libdecor_frame_close_dylibloader_orig_libdecor
#define libdecor_frame_map libdecor_frame_map_dylibloader_orig_libdecor
#define libdecor_frame_get_xdg_surface libdecor_frame_get_xdg_surface_dylibloader_orig_libdecor
#define libdecor_frame_get_xdg_toplevel libdecor_frame_get_xdg_toplevel_dylibloader_orig_libdecor
#define libdecor_state_new libdecor_state_new_dylibloader_orig_libdecor
#define libdecor_state_free libdecor_state_free_dylibloader_orig_libdecor
#define libdecor_configuration_get_content_size libdecor_configuration_get_content_size_dylibloader_orig_libdecor
#define libdecor_configuration_get_window_state libdecor_configuration_get_window_state_dylibloader_orig_libdecor
#include <libdecor-0/libdecor.h>
#undef libdecor_unref
#undef libdecor_new
#undef libdecor_get_fd
#undef libdecor_dispatch
#undef libdecor_decorate
#undef libdecor_frame_ref
#undef libdecor_frame_unref
#undef libdecor_frame_set_visibility
#undef libdecor_frame_is_visible
#undef libdecor_frame_set_parent
#undef libdecor_frame_set_title
#undef libdecor_frame_get_title
#undef libdecor_frame_set_app_id
#undef libdecor_frame_set_capabilities
#undef libdecor_frame_unset_capabilities
#undef libdecor_frame_has_capability
#undef libdecor_frame_show_window_menu
#undef libdecor_frame_popup_grab
#undef libdecor_frame_popup_ungrab
#undef libdecor_frame_translate_coordinate
#undef libdecor_frame_set_min_content_size
#undef libdecor_frame_set_max_content_size
#undef libdecor_frame_resize
#undef libdecor_frame_move
#undef libdecor_frame_commit
#undef libdecor_frame_set_minimized
#undef libdecor_frame_set_maximized
#undef libdecor_frame_unset_maximized
#undef libdecor_frame_set_fullscreen
#undef libdecor_frame_unset_fullscreen
#undef libdecor_frame_is_floating
#undef libdecor_frame_close
#undef libdecor_frame_map
#undef libdecor_frame_get_xdg_surface
#undef libdecor_frame_get_xdg_toplevel
#undef libdecor_state_new
#undef libdecor_state_free
#undef libdecor_configuration_get_content_size
#undef libdecor_configuration_get_window_state
#ifdef __cplusplus
extern "C" {
#endif
#define libdecor_unref libdecor_unref_dylibloader_wrapper_libdecor
#define libdecor_new libdecor_new_dylibloader_wrapper_libdecor
#define libdecor_get_fd libdecor_get_fd_dylibloader_wrapper_libdecor
#define libdecor_dispatch libdecor_dispatch_dylibloader_wrapper_libdecor
#define libdecor_decorate libdecor_decorate_dylibloader_wrapper_libdecor
#define libdecor_frame_ref libdecor_frame_ref_dylibloader_wrapper_libdecor
#define libdecor_frame_unref libdecor_frame_unref_dylibloader_wrapper_libdecor
#define libdecor_frame_set_visibility libdecor_frame_set_visibility_dylibloader_wrapper_libdecor
#define libdecor_frame_is_visible libdecor_frame_is_visible_dylibloader_wrapper_libdecor
#define libdecor_frame_set_parent libdecor_frame_set_parent_dylibloader_wrapper_libdecor
#define libdecor_frame_set_title libdecor_frame_set_title_dylibloader_wrapper_libdecor
#define libdecor_frame_get_title libdecor_frame_get_title_dylibloader_wrapper_libdecor
#define libdecor_frame_set_app_id libdecor_frame_set_app_id_dylibloader_wrapper_libdecor
#define libdecor_frame_set_capabilities libdecor_frame_set_capabilities_dylibloader_wrapper_libdecor
#define libdecor_frame_unset_capabilities libdecor_frame_unset_capabilities_dylibloader_wrapper_libdecor
#define libdecor_frame_has_capability libdecor_frame_has_capability_dylibloader_wrapper_libdecor
#define libdecor_frame_show_window_menu libdecor_frame_show_window_menu_dylibloader_wrapper_libdecor
#define libdecor_frame_popup_grab libdecor_frame_popup_grab_dylibloader_wrapper_libdecor
#define libdecor_frame_popup_ungrab libdecor_frame_popup_ungrab_dylibloader_wrapper_libdecor
#define libdecor_frame_translate_coordinate libdecor_frame_translate_coordinate_dylibloader_wrapper_libdecor
#define libdecor_frame_set_min_content_size libdecor_frame_set_min_content_size_dylibloader_wrapper_libdecor
#define libdecor_frame_set_max_content_size libdecor_frame_set_max_content_size_dylibloader_wrapper_libdecor
#define libdecor_frame_resize libdecor_frame_resize_dylibloader_wrapper_libdecor
#define libdecor_frame_move libdecor_frame_move_dylibloader_wrapper_libdecor
#define libdecor_frame_commit libdecor_frame_commit_dylibloader_wrapper_libdecor
#define libdecor_frame_set_minimized libdecor_frame_set_minimized_dylibloader_wrapper_libdecor
#define libdecor_frame_set_maximized libdecor_frame_set_maximized_dylibloader_wrapper_libdecor
#define libdecor_frame_unset_maximized libdecor_frame_unset_maximized_dylibloader_wrapper_libdecor
#define libdecor_frame_set_fullscreen libdecor_frame_set_fullscreen_dylibloader_wrapper_libdecor
#define libdecor_frame_unset_fullscreen libdecor_frame_unset_fullscreen_dylibloader_wrapper_libdecor
#define libdecor_frame_is_floating libdecor_frame_is_floating_dylibloader_wrapper_libdecor
#define libdecor_frame_close libdecor_frame_close_dylibloader_wrapper_libdecor
#define libdecor_frame_map libdecor_frame_map_dylibloader_wrapper_libdecor
#define libdecor_frame_get_xdg_surface libdecor_frame_get_xdg_surface_dylibloader_wrapper_libdecor
#define libdecor_frame_get_xdg_toplevel libdecor_frame_get_xdg_toplevel_dylibloader_wrapper_libdecor
#define libdecor_state_new libdecor_state_new_dylibloader_wrapper_libdecor
#define libdecor_state_free libdecor_state_free_dylibloader_wrapper_libdecor
#define libdecor_configuration_get_content_size libdecor_configuration_get_content_size_dylibloader_wrapper_libdecor
#define libdecor_configuration_get_window_state libdecor_configuration_get_window_state_dylibloader_wrapper_libdecor
extern void (*libdecor_unref_dylibloader_wrapper_libdecor)(struct libdecor*);
extern struct libdecor* (*libdecor_new_dylibloader_wrapper_libdecor)(struct wl_display*,struct libdecor_interface*);
extern int (*libdecor_get_fd_dylibloader_wrapper_libdecor)(struct libdecor*);
extern int (*libdecor_dispatch_dylibloader_wrapper_libdecor)(struct libdecor*, int);
extern struct libdecor_frame* (*libdecor_decorate_dylibloader_wrapper_libdecor)(struct libdecor*,struct wl_surface*,struct libdecor_frame_interface*, void*);
extern void (*libdecor_frame_ref_dylibloader_wrapper_libdecor)(struct libdecor_frame*);
extern void (*libdecor_frame_unref_dylibloader_wrapper_libdecor)(struct libdecor_frame*);
extern void (*libdecor_frame_set_visibility_dylibloader_wrapper_libdecor)(struct libdecor_frame*, bool);
extern bool (*libdecor_frame_is_visible_dylibloader_wrapper_libdecor)(struct libdecor_frame*);
extern void (*libdecor_frame_set_parent_dylibloader_wrapper_libdecor)(struct libdecor_frame*,struct libdecor_frame*);
extern void (*libdecor_frame_set_title_dylibloader_wrapper_libdecor)(struct libdecor_frame*,const char*);
extern const char* (*libdecor_frame_get_title_dylibloader_wrapper_libdecor)(struct libdecor_frame*);
extern void (*libdecor_frame_set_app_id_dylibloader_wrapper_libdecor)(struct libdecor_frame*,const char*);
extern void (*libdecor_frame_set_capabilities_dylibloader_wrapper_libdecor)(struct libdecor_frame*,enum libdecor_capabilities);
extern void (*libdecor_frame_unset_capabilities_dylibloader_wrapper_libdecor)(struct libdecor_frame*,enum libdecor_capabilities);
extern bool (*libdecor_frame_has_capability_dylibloader_wrapper_libdecor)(struct libdecor_frame*,enum libdecor_capabilities);
extern void (*libdecor_frame_show_window_menu_dylibloader_wrapper_libdecor)(struct libdecor_frame*,struct wl_seat*, uint32_t, int, int);
extern void (*libdecor_frame_popup_grab_dylibloader_wrapper_libdecor)(struct libdecor_frame*,const char*);
extern void (*libdecor_frame_popup_ungrab_dylibloader_wrapper_libdecor)(struct libdecor_frame*,const char*);
extern void (*libdecor_frame_translate_coordinate_dylibloader_wrapper_libdecor)(struct libdecor_frame*, int, int, int*, int*);
extern void (*libdecor_frame_set_min_content_size_dylibloader_wrapper_libdecor)(struct libdecor_frame*, int, int);
extern void (*libdecor_frame_set_max_content_size_dylibloader_wrapper_libdecor)(struct libdecor_frame*, int, int);
extern void (*libdecor_frame_resize_dylibloader_wrapper_libdecor)(struct libdecor_frame*,struct wl_seat*, uint32_t,enum libdecor_resize_edge);
extern void (*libdecor_frame_move_dylibloader_wrapper_libdecor)(struct libdecor_frame*,struct wl_seat*, uint32_t);
extern void (*libdecor_frame_commit_dylibloader_wrapper_libdecor)(struct libdecor_frame*,struct libdecor_state*,struct libdecor_configuration*);
extern void (*libdecor_frame_set_minimized_dylibloader_wrapper_libdecor)(struct libdecor_frame*);
extern void (*libdecor_frame_set_maximized_dylibloader_wrapper_libdecor)(struct libdecor_frame*);
extern void (*libdecor_frame_unset_maximized_dylibloader_wrapper_libdecor)(struct libdecor_frame*);
extern void (*libdecor_frame_set_fullscreen_dylibloader_wrapper_libdecor)(struct libdecor_frame*,struct wl_output*);
extern void (*libdecor_frame_unset_fullscreen_dylibloader_wrapper_libdecor)(struct libdecor_frame*);
extern bool (*libdecor_frame_is_floating_dylibloader_wrapper_libdecor)(struct libdecor_frame*);
extern void (*libdecor_frame_close_dylibloader_wrapper_libdecor)(struct libdecor_frame*);
extern void (*libdecor_frame_map_dylibloader_wrapper_libdecor)(struct libdecor_frame*);
extern struct xdg_surface* (*libdecor_frame_get_xdg_surface_dylibloader_wrapper_libdecor)(struct libdecor_frame*);
extern struct xdg_toplevel* (*libdecor_frame_get_xdg_toplevel_dylibloader_wrapper_libdecor)(struct libdecor_frame*);
extern struct libdecor_state* (*libdecor_state_new_dylibloader_wrapper_libdecor)( int, int);
extern void (*libdecor_state_free_dylibloader_wrapper_libdecor)(struct libdecor_state*);
extern bool (*libdecor_configuration_get_content_size_dylibloader_wrapper_libdecor)(struct libdecor_configuration*,struct libdecor_frame*, int*, int*);
extern bool (*libdecor_configuration_get_window_state_dylibloader_wrapper_libdecor)(struct libdecor_configuration*,enum libdecor_window_state*);
int initialize_libdecor(int verbose);
#ifdef __cplusplus
}
#endif
#endif