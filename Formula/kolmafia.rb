class Kolmafia < Formula
  desc "Interface for online game"
  homepage "https://kolmafia.us"
  url "https://svn.code.sf.net/p/kolmafia/code/", revision: version
  version "20947"
  license "BSD-3-Clause"
  head "https://svn.code.sf.net/p/kolmafia/code/"

  livecheck do
    url :head
    strategy :page_match
    regex(/Revision (\d+)/i)
  end

  bottle do
    root_url "https://github.com/jonchang/homebrew-tap/releases/download/kolmafia-20947"
    sha256 cellar: :any_skip_relocation, catalina:     "c9272d74b81ace0c0f103d37d1c65b3dae2a3ccca66e84ceabadf98fa2fbcd07"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "9329889b39dfbf253a39a9736d7e845f7b286327aee6da0aed9176006830a1cd"
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
