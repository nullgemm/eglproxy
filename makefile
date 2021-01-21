NAME = eglproxy
NATIVE ?= FALSE

ifeq ($(NATIVE), TRUE)
WINDOWS_VERSION = 10
WINDOWS_VERSION_SDK = 10.0.19041.0
WINDOWS_VERSION_VISUAL_STUDIO = 2019
WINDOWS_VERSION_MSVC = 14.28.29333

LIB = "/c/Program Files (x86)/Microsoft Visual Studio/$\
$(WINDOWS_VERSION_VISUAL_STUDIO)/BuildTools/VC/Tools/MSVC/$\
$(WINDOWS_VERSION_MSVC)/bin/Hostx64/x64/lib.exe"
CC = "/c/Program Files (x86)/Microsoft Visual Studio/$\
$(WINDOWS_VERSION_VISUAL_STUDIO)/BuildTools/VC/Tools/MSVC/$\
$(WINDOWS_VERSION_MSVC)/bin/Hostx64/x64/cl.exe"

INCL+= -I"/c/Program Files (x86)/Windows Kits/$\
$(WINDOWS_VERSION)/Include/$\
$(WINDOWS_VERSION_SDK)/ucrt"
INCL+= -I"/c/Program Files (x86)/Windows Kits/$\
$(WINDOWS_VERSION)/Include/$\
$(WINDOWS_VERSION_SDK)/um"
INCL+= -I"/c/Program Files (x86)/Windows Kits/$\
$(WINDOWS_VERSION)/Include/$\
$(WINDOWS_VERSION_SDK)/shared"
INCL+= -I"/c/Program Files (x86)/Microsoft Visual Studio/$\
$(WINDOWS_VERSION_VISUAL_STUDIO)/BuildTools/VC/Tools/MSVC/$\
$(WINDOWS_VERSION_MSVC)/include"

LINK = -D_USRDLL -D_WINDLL Gdi32.lib User32.lib opengl32.lib

LINK_WINDOWS+= -LIBPATH:"/c/Program Files (x86)/Windows Kits/$\
$(WINDOWS_VERSION)/Lib/$\
$(WINDOWS_VERSION_SDK)/um/x64"
LINK_WINDOWS+= -LIBPATH:"/c/Program Files (x86)/Microsoft Visual Studio/$\
$(WINDOWS_VERSION_VISUAL_STUDIO)/BuildTools/VC/Tools/MSVC/$\
$(WINDOWS_VERSION_MSVC)/lib/spectre/x64"
LINK_WINDOWS+= -LIBPATH:"/c/Program Files (x86)/Windows Kits/$\
$(WINDOWS_VERSION)/Lib/$\
$(WINDOWS_VERSION_SDK)/ucrt/x64"
else
CC = x86_64-w64-mingw32-gcc

FLAGS+= -std=c99 -pedantic -g
FLAGS+= -Wall -Wextra -Werror=vla -Werror
FLAGS+= -Wno-unused-parameter
FLAGS+= -Wno-cast-function-type

LINK = -shared -lgdi32 -lopengl32
endif

FLAGS+= -DUNICODE -D_UNICODE
FLAGS+= -DWINVER=0x0A00 -D_WIN32_WINNT=0x0A00
FLAGS+= -DCINTERFACE -DCOBJMACROS

BIND = bin
OBJD = obj
SRCD = src
INCD = inc

INCL+= -I$(SRCD)
INCL+= -I$(INCD)

SRCS = $(SRCD)/eglproxy.c
SRCS+= $(SRCD)/egl_proc.c
SRCS+= $(SRCD)/egl_wgl.c

ifeq ($(NATIVE), TRUE)
SRCS_OBJS := $(patsubst %.c,$(OBJD)/%.obj,$(SRCS))
else
SRCS_OBJS := $(patsubst %.c,$(OBJD)/%.o,$(SRCS))
endif

# aliases
.PHONY: final
final: $(INCD) $(BIND)/$(NAME).dll $(BIND)/$(NAME).lib

# get EGL headers
$(INCD):
	@echo "downloading EGL headers"
	@mkdir -p $@/EGL
	@mkdir -p $@/KHR
	@curl -L "https://www.khronos.org/registry/EGL/api/EGL/egl.h" -o $@/EGL/egl.h
	@curl -L "https://www.khronos.org/registry/EGL/api/EGL/eglext.h" -o $@/EGL/eglext.h
	@curl -L "https://www.khronos.org/registry/EGL/api/EGL/eglplatform.h" -o $@/EGL/eglplatform.h
	@curl -L "https://www.khronos.org/registry/EGL/api/KHR/khrplatform.h" -o $@/KHR/khrplatform.h

# generic compiling
$(OBJD)/%.o: %.c
	@echo "building object $@"
	@mkdir -p $(@D)
	@$(CC) $(INCL) $(FLAGS) -c -o $@ $<

$(OBJD)/%.obj: %.c
	@echo "building object $@"
	@mkdir -p $(@D)
	@$(CC) $(INCL) $(FLAGS) -Fo$@ -c $<

# libraries generation
$(BIND)/$(NAME).dll: $(SRCS_OBJS)
	@echo "compiling executable $@"
	@mkdir -p $(@D)
ifeq ($(NATIVE), TRUE)
	@$(CC) $(LINK) $^ -link -DLL -OUT:$@ $(LINK_WINDOWS)
else
	@$(CC) -o $@ $^ $(LINK)
endif

$(BIND)/$(NAME).lib: $(SRCS_OBJS)
	@echo "compiling executable $@"
	@mkdir -p $(@D)
ifeq ($(NATIVE), TRUE)
	@$(LIB) /OUT:$@ $^
else
	@ar -rcs $@ $^
endif

# tools
clean:
	@echo "cleaning"
	@rm -rf $(BIND) $(OBJD)

remotes:
	@echo "registering remotes"
	@git remote add github git@github.com:nullgemm/$(NAME).git
	@git remote add gitea ssh://git@git.nullgemm.fr:2999/nullgemm/$(NAME).git
