final: inc bin/$(NAME).dll

inc:
	make/scripts/egl_get.sh

bin/$(NAME).dll: $(OBJ)
	mkdir -p $(@D)
	$(CC) $(LDFLAGS) -shared -o $@ $^ $(LDLIBS) -Wl,--out-implib,$(@D)/lib$(NAME).a
