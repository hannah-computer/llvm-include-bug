# ???

libclang's behaviour changes depending on the linkage:

- dynamically, everything is fine.
- statically, against the mac OS system libc++, everything is fine.
- statically, against the libc++ shipped with the compiler, we're getting absurd behavior: while the lexer is searching for source file for the `#include <cassert>` line, it checks `/my/includes` first, since this is given as a search path with the `-I` flag. It's not there, so normally it'd continue and find it in the next path it checks, `/usr/include`. But not here! For some reason, the "not found" status returned from VFS' openFileForRead is now treated as fatal, [produces an error diagnostic](https://github.com/llvm/llvm-project/blob/c54bc306c38b695e6e713002ef9608c36c63ce9a/clang/lib/Lex/HeaderSearch.cpp#L459) and stops the parse -- though funnily the lexer actually continues and reads `/usr/include/cassert` as expected.

I've already wasted a day isolating this and don't have the nerves left to debug where the behaviour difference comes from, maybe this nerdsnipes someone :)
