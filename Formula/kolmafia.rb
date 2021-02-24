class Kolmafia < Formula
  desc "Interface for online game"
  homepage "https://kolmafia.us"
  url "https://svn.code.sf.net/p/kolmafia/code/", revision: version
  version "20653"
  license "BSD-3-Clause"
  head "https://svn.code.sf.net/p/kolmafia/code/"

  livecheck do
    url :head
    strategy :page_match
    regex(/Revision (\d+)/i)
  end

  bottle do
    root_url "https://github.com/jonchang/homebrew-tap/releases/download/kolmafia-20653"
    sha256 cellar: :any_skip_relocation, catalina:     "fc0527027152dfcc6673f27c287bfcae2ac72302240f0fa0dcd71ca887ab94b9"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "f03bcd24a93bb4ad0df3cc28c7e0f116c8fbcdb3f03c362dc110fc146c0e3d86"
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
