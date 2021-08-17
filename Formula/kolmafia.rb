class Kolmafia < Formula
  desc "Interface for online game"
  homepage "https://kolmafia.us"
  url "https://svn.code.sf.net/p/kolmafia/code/", revision: version
  version "20831"
  license "BSD-3-Clause"
  head "https://svn.code.sf.net/p/kolmafia/code/"

  livecheck do
    url :head
    strategy :page_match
    regex(/Revision (\d+)/i)
  end

  bottle do
    root_url "https://github.com/jonchang/homebrew-tap/releases/download/kolmafia-20831"
    sha256 cellar: :any_skip_relocation, catalina:     "37c3ee3aa31c9ee096792ecb0e7df20c8c41fe49d9c8a5133a3eeb417f19fdab"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "087461c48d34363fe99ca6bcab8b42776ee1bf565f9ed9bce311af0a965c65d7"
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
