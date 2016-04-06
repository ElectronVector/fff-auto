
#include <string.h>
#include "fff.h"

DEFINE_FFF_GLOBALS;

FAKE_VOID_FUNC(display_turnOffStatusLed);
FAKE_VOID_FUNC(display_turnOnStatusLed);
FAKE_VOID_FUNC(display_setVolume, int);
FAKE_VOID_FUNC(display_setModeToMinimum);
FAKE_VOID_FUNC(display_setModeToMaximum);
FAKE_VOID_FUNC(display_setModeToAverage);
FAKE_VALUE_FUNC(bool, display_isError);
FAKE_VOID_FUNC(display_powerDown);
FAKE_VOID_FUNC(display_getKeyboardEntry, char *, int);

typedef void (*displayCompleteCallback) (void);
FAKE_VOID_FUNC(display_updateData, int, displayCompleteCallback);

#define RESET_MOCK_DISPLAY() \
    RESET_FAKE(display_turnOffStatusLed);   \
    RESET_FAKE(display_turnOnStatusLed);    \
    RESET_FAKE(display_setVolume);          \
    RESET_FAKE(display_setModeToMinimum);   \
    RESET_FAKE(display_setModeToMaximum);   \
    RESET_FAKE(display_setModeToAverage);   \
    RESET_FAKE(display_isError);            \
    RESET_FAKE(display_powerDown);          \
    RESET_FAKE(display_getKeyboardEntry);   
