#include <HsFFI.h>

#include "SDL_test_common.h"

extern void haskell_main(char *resourcePath);
extern void __stginit_Epidemiczm0zi0zi1_AndroidMain (void);

int main(int argc, char *argv[])
{
  hs_init(&argc, &argv);
  hs_add_root(__stginit_Epidemiczm0zi0zi1_AndroidMain);
  haskell_main(argv[1]);
  hs_exit();
  return 0;
}
