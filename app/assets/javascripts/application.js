document.addEventListener("DOMContentLoaded", () => {
  const button = document.querySelector("#webauthn-registration")
  const status = document.querySelector("#webauthn-registration-status")

  if (!button) return

  button.addEventListener("click", async () => {
    button.disabled = true
    status.textContent = ""

    try {
      if (!globalThis.PublicKeyCredential?.parseCreationOptionsFromJSON) {
        throw new Error("このブラウザはパスキー登録に対応していません。")
      }

      const response = await fetch(button.dataset.optionsUrl, {
        method: "POST",
        headers: {
          "Accept": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        }
      })

      if (!response.ok) throw new Error("パスキーの登録を開始できませんでした。")

      const publicKey = PublicKeyCredential.parseCreationOptionsFromJSON(await response.json())
      const credential = await navigator.credentials.create({ publicKey })
      const verificationResponse = await fetch(button.dataset.createUrl, {
        method: "POST",
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ credential: credential.toJSON() })
      })

      if (!verificationResponse.ok) throw new Error("パスキーを登録できませんでした。")

      status.textContent = "パスキーを登録しました。"
    } catch (error) {
      status.textContent = error.name === "NotAllowedError" ? "パスキーの登録をキャンセルしました。" : error.message
    } finally {
      button.disabled = false
    }
  })
})
