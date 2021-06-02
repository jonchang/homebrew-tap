class Kolmafia < Formula
  desc "Interface for online game"
  homepage "https://kolmafia.us"
  url "https://svn.code.sf.net/p/kolmafia/code/", revision: version
  version "20747"
  license "BSD-3-Clause"
  head "https://svn.code.sf.net/p/kolmafia/code/"

  livecheck do
    url :head
    strategy :page_match
    regex(/Revision (\d+)/i)
  end

  bottle do
    root_url "https://github.com/jonchang/homebrew-tap/releases/download/kolmafia-20746"
    sha256 cellar: :any_skip_relocation, catalina:     "f80fa80d735b169b1a0d20aebab92a4989f174b0f4a3c3eb843796fefa71dd8a"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "93b2c621acd3feb184d91db18a26f8d90da5511169ca8395822c1e51d5133158"
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
