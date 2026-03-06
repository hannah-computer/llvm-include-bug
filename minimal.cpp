
#include <memory>

#include <clang/Frontend/CompilerInstance.h>
#include <clang/Frontend/FrontendAction.h>
#include <clang/Tooling/Tooling.h>

using namespace clang;
using namespace clang::tooling;
using namespace llvm;
using namespace llvm::vfs;
using namespace std;

class MinimalConsumer : public ASTConsumer {};

class MinimalAction : public ASTFrontendAction {
public:
  unique_ptr<ASTConsumer> CreateASTConsumer(CompilerInstance &,
                                            StringRef) override {
    return make_unique<MinimalConsumer>();
  }
};

int main() {

  auto fs = makeIntrusiveRefCnt<InMemoryFileSystem>();

  fs->addFile("/my/includes/unrelated.xyz", 0,
              MemoryBuffer::getMemBufferCopy("ignore"));
  fs->addFile("/usr/include/cassert", 0,
              MemoryBuffer::getMemBufferCopy("int good = 0;"));
  fs->addFile("/my/source.cpp", 0,
              MemoryBuffer::getMemBufferCopy("#include <cassert>"));

  vector<string> commandLine{
      "/bin/my-tool",
      "-I",
      "/my/includes",
      "/my/source.cpp",
  };

  FileSystemOptions opts;
  // opts.WorkingDir = "/";
  auto files = makeIntrusiveRefCnt<FileManager>(opts, fs);

  auto action = make_unique<MinimalAction>();
  auto pch = make_shared<PCHContainerOperations>();
  ToolInvocation invocation(commandLine, std::move(action), files.get(), pch);

  return invocation.run() ? 0 : 1;
}
