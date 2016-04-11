#include <HsFFI.h>

#include "SDL_test_common.h"

extern void haskell_main(char *resourcePath);

int main(int argc, char *argv[])
{
  hs_init(&argc, &argv);
  haskell_main(argv[1]);
  hs_exit();
  return 0;
}
