class Supaswap < Formula
  desc "Switch Supabase CLI accounts in one command"
  homepage "https://github.com/ExoticPengy/homebrew-supaswap"
  url "https://github.com/ExoticPengy/homebrew-supaswap/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "4f33651a82cd766506002f20d3e4147a0bc5a2b64b6558febfabd68fade0987f"
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
