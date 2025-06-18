CFLAGS  += -I. -Wall -fPIC
LDFLAGS += -lm -lrt

DEPS    = ../jive.h ../common.h ../log.h

SOURCES += spectrum.c vumeter.c kiss_fft.c visualizer.c

OBJECTS = $(SOURCES:.c=.o)

all: $(OBJECTS)

$(OBJECTS): $(DEPS)

.c.o:
	$(CC) $(CFLAGS) $< -c -o $@

clean:
	rm -f $(OBJECTS)
