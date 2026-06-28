const csrfToken = () => document.querySelector('meta[name="csrf-token"]').content

document.addEventListener("DOMContentLoaded", () => {
  const registrationButton = document.querySelector("#webauthn-registration")
  const registrationStatus = document.querySelector("#webauthn-registration-status")

  registrationButton?.addEventListener("click", async () => {
    registrationButton.disabled = true
    registrationStatus.textContent = ""

    try {
      if (!globalThis.PublicKeyCredential?.parseCreationOptionsFromJSON) {
        throw new Error("このブラウザはパスキー登録に対応していません。")
      }

      const response = await fetch(registrationButton.dataset.optionsUrl, {
        method: "POST",
        headers: {
          "Accept": "application/json",
          "X-CSRF-Token": csrfToken()
        }
      })

      if (!response.ok) throw new Error("パスキーの登録を開始できませんでした。")

      const publicKey = PublicKeyCredential.parseCreationOptionsFromJSON(await response.json())
      const credential = await navigator.credentials.create({ publicKey })
      const verificationResponse = await fetch(registrationButton.dataset.createUrl, {
        method: "POST",
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken()
        },
        body: JSON.stringify({ credential: credential.toJSON() })
      })

      if (!verificationResponse.ok) throw new Error("パスキーを登録できませんでした。")

      registrationStatus.textContent = "パスキーを登録しました。"
    } catch (error) {
      registrationStatus.textContent = error.name === "NotAllowedError" ? "パスキーの登録をキャンセルしました。" : error.message
    } finally {
      registrationButton.disabled = false
    }
  })

  const authenticationButton = document.querySelector("#webauthn-authentication")
  const authenticationStatus = document.querySelector("#webauthn-authentication-status")

  authenticationButton?.addEventListener("click", async () => {
    authenticationButton.disabled = true
    authenticationStatus.textContent = ""

    try {
      if (!globalThis.PublicKeyCredential?.parseRequestOptionsFromJSON) {
        throw new Error("このブラウザはパスキーログインに対応していません。")
      }

      const response = await fetch(authenticationButton.dataset.optionsUrl, {
        method: "POST",
        headers: {
          "Accept": "application/json",
          "X-CSRF-Token": csrfToken()
        }
      })

      if (!response.ok) throw new Error("パスキーログインを開始できませんでした。")

      const publicKey = PublicKeyCredential.parseRequestOptionsFromJSON(await response.json())
      const credential = await navigator.credentials.get({ publicKey })
      const verificationResponse = await fetch(authenticationButton.dataset.createUrl, {
        method: "POST",
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken()
        },
        body: JSON.stringify({ credential: credential.toJSON() })
      })

      if (!verificationResponse.ok) throw new Error("パスキーでログインできませんでした。")

      window.location.assign("/")
    } catch (error) {
      authenticationStatus.textContent = error.name === "NotAllowedError" ? "パスキーログインをキャンセルしました。" : error.message
      authenticationButton.disabled = false
    }
  })
})
