#make file for httpclient

#variables
CC=gcc
CFLAGS=-c -g -shared -Wall -I/usr/local/include
LDFLAGS=-L/usr/local/lib -lcurl -fPIC
SOURCES=curlclient.c
OBJECTS=$(SOURCES:.c=.o)
EXECUTABLE=curlclient

all: $(SOURCES) $(EXECUTABLE) 

$(EXECUTABLE): $(OBJECTS)
	$(CC) $(LDFLAGS) $(OBJECTS) -o $@

.c .o: 
	$(CC) $(CFLAGS) $< -o $@

shared:
	$(CC) -O -Wl,-soname,curlclient.so -o curlcient.so  $(OBJECTS) $(LDFLAGS)
	$(CC)  $(CFLAGS)  -o curlclient.so  $(OBJECTS)

clean:
	rm -rf *o $(EXECUTABLE)
