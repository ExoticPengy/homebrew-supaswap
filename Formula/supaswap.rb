class Supaswap < Formula
  desc "Switch Supabase CLI accounts in one command"
  homepage "https://github.com/ExoticPengy/homebrew-supaswap"
  url "https://github.com/ExoticPengy/homebrew-supaswap/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "daa6336c390ec9eaf3eac6c49c0d3220d30a10bfa364780a07dd41aa711e230d"
  license "MIT"
  head "https://github.com/ExoticPengy/homebrew-supaswap.git", branch: "main"

  depends_on :macos

  def install
    bin.install "supaswap"
  end

  test do
    assert_match "usage", shell_output("#{bin}/supaswap 2>&1", 1)
  end
end
