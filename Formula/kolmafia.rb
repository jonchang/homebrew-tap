class Kolmafia < Formula
  desc "Interface for online game"
  homepage "https://kolmafia.us"
  url "https://svn.code.sf.net/p/kolmafia/code/", revision: version
  version "20746"
  license "BSD-3-Clause"
  head "https://svn.code.sf.net/p/kolmafia/code/"

  livecheck do
    url :head
    strategy :page_match
    regex(/Revision (\d+)/i)
  end

  bottle do
    root_url "https://github.com/jonchang/homebrew-tap/releases/download/kolmafia-20745"
    sha256 cellar: :any_skip_relocation, catalina:     "7b65a0f91039aa143a74270a442991982f7734bb2f1f92d4340b4cb43b63aa9d"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "8b6ef33986c1cda0804587e688a29c24a0509043fb2660e2ea5da2df0e0c3e92"
  end

  depends_on "ant" => :build
  depends_on "openjdk"

  def install
    system "ant", "daily", "-Drevision=#{version}"
    libexec.install Dir["dist/*.jar"]
    bin.write_jar_script libexec/"KoLmafia-#{version}.jar", "kolmafia"
  end

  test do
    assert_match(version.to_s, shell_output("#{bin}/kolmafia --version"))
  end
end
