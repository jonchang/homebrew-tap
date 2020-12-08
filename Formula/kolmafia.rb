class SourceforgeTarballDownloadStrategy < AbstractFileDownloadStrategy
  def fetch
    # Must POST to the tarball URL in order to kick off the generation job
    ohai "Downloading #{url}"
    temp = Tempfile.new(Digest::SHA256.hexdigest(url))
    begin
      curl "-X", "POST", "--location", "--create-dirs", "--output", temp.path, url, *meta.fetch(:curl_args, [])
    rescue ErrorDuringExecution
      raise CurlDownloadStrategyError, url
    end
    new_url = File.open(temp.path).read.match(%r{"(https://sourceforge.net/code-snapshots/svn/[^"]+.zip)"})[1]

    # Wait for Sourceforge to generate the tarball...
    sleep 10
    ohai "Downloading #{new_url}"
    begin
      curl "--location", "--create-dirs", "--output", temporary_path, new_url, *meta.fetch(:curl_args, [])
    rescue ErrorDuringExecution
      raise CurlDownloadStrategyError, new_url
    end

    ignore_interrupts do
      cached_location.dirname.mkpath
      temporary_path.rename(cached_location)
      symlink_location.dirname.mkpath
    end
    FileUtils.ln_s cached_location.relative_path_from(symlink_location.dirname), symlink_location, force: true
  end
end

class Kolmafia < Formula
  desc "Interface for online game"
  homepage "https://kolmafia.us"
  url "https://sourceforge.net/p/kolmafia/code/20548/tarball", using: SourceforgeTarballDownloadStrategy
  version "20548"
  sha256 "12b963c864bae92dacb1bb1e3a983bfe7eab7b86765d6d59663d9ed9a5eb5420"
  license "BSD-3-Clause"
  head "https://svn.code.sf.net/p/kolmafia/code/"

  livecheck do
    url :head
    strategy :page_match
    regex(/Revision (\d+)/i)
  end

  bottle do
    root_url "https://github.com/jonchang/homebrew-tap/releases/download/kolmafia-20548"
    cellar :any_skip_relocation
    sha256 "c6caef78ce5ee775ee6d29df3abda8ee189cdedc8958b502921a457451ec596e" => :catalina
    sha256 "4a6c64ad4f5d08def9a662a1281711da3311e3c40c9448c84221e92d592d7e02" => :x86_64_linux
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
