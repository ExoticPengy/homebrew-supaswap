class Supaswap < Formula
  desc "Switch Supabase CLI accounts in one command"
  homepage "https://github.com/ExoticPengy/homebrew-supaswap"
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
