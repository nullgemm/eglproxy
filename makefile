NAME = eglproxy
NATIVE ?= FALSE

ifeq ($(NATIVE), TRUE)
WINDOWS_VERSION_VISUAL_STUDIO = 2019
WINDOWS_VERSION_MSVC = 14.28.29333
CC = "/c/Program Files (x86)/Microsoft Visual Studio/$\
$(WINDOWS_VERSION_VISUAL_STUDIO)/BuildTools/VC/Tools/MSVC/$\
$(WINDOWS_VERSION_MSVC)/bin/Hostx64/x64/cl.exe"
else
CC = x86_64-w64-mingw32-gcc
FLAGS = -std=c99 -pedantic -g
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

INCL = -I$(SRCD)
INCL+= -I$(INCD)

SRCS = $(SRCD)/eglproxy.c
SRCS+= $(SRCD)/egl_proc.c
SRCS+= $(SRCD)/egl_wgl.c

SRCS_OBJS := $(patsubst %.c,$(OBJD)/%.o,$(SRCS))

# aliases
.PHONY: final
final: $(INCD) $(BIND)/$(NAME).lib $(BIND)/$(NAME).dll

# get EGL headers
$(INCD):
	@echo "downloading EGL headers"
	@mkdir -p $@/EGL
	@mkdir -p $@/KHR
	@curl -L "https://www.khronos.org/registry/EGL/api/EGL/egl.h" -o $@/EGL/egl.h
	@curl -L "https://www.khronos.org/registry/EGL/api/EGL/eglext.h" -o $@/EGL/eglext.h
	@curl -L "https://www.khronos.org/registry/EGL/api/EGL/eglplatform.h" -o $@/EGL/eglplatform.h
	@curl -L "https://www.khronos.org/registry/EGL/api/KHR/khrplatform.h" -o $@/KHR/khrplatform.h

# generic compiling command
$(OBJD)/%.o: %.c
	@echo "building object $@"
	@mkdir -p $(@D)
	@$(CC) $(INCL) $(FLAGS) -c -o $@ $<

# final executable
$(BIND)/$(NAME).dll: $(SRCS_OBJS)
	@echo "compiling executable $@"
	@mkdir -p $(@D)
	@$(CC) -o $@ $^ $(LINK)

$(BIND)/$(NAME).lib: $(SRCS_OBJS)
	@echo "compiling executable $@"
	@mkdir -p $(@D)
	@ar -rcs $@ $^

# tools
clean:
	@echo "cleaning"
	@rm -rf $(BIND) $(OBJD)

remotes:
	@echo "registering remotes"
	@git remote add github git@github.com:nullgemm/$(NAME).git
	@git remote add gitea ssh://git@git.nullgemm.fr:2999/nullgemm/$(NAME).git
