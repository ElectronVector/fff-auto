
#include <string.h>
#include "fff.h"

DEFINE_FFF_GLOBALS;

FAKE_VOID_FUNC(printer_print, char *);

#define RESET_MOCK_PRINTER() \
    RESET_FAKE(printer_print);
