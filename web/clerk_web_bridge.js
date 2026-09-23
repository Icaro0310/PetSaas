(function () {
  var fapi = 'https://climbing-burro-4910.clerk.accounts.dev';
  var publishableKey = 'pk_test_Y2xpbWJpbmctYnVycm8tNDkxMC5jbGVyay5hY2NvdW50cy5kZXYk';
  var resolveReady;
  var rejectReady;

  function serializeUser(clerk) {
    var user = clerk.user;
    if (!user) return null;
    return {
      id: user.id,
      email: user.primaryEmailAddress
        ? user.primaryEmailAddress.emailAddress
        : null,
    };
  }

  function loadScript(src, key) {
    return new Promise(function (resolve, reject) {
      var script = document.createElement('script');
      script.async = true;
      script.crossOrigin = 'anonymous';
      script.onload = resolve;
      script.onerror = function () {
        reject(new Error('ClerkJS script failed to load'));
      };
      if (key) script.setAttribute('data-clerk-publishable-key', key);
      script.src = src;
      document.head.appendChild(script);
    });
  }

  window.PetCareClerkReady = new Promise(function (resolve, reject) {
    resolveReady = resolve;
    rejectReady = reject;
  });
  window.PetCareClerkReady.catch(function () {});

  var baseHref = document.querySelector('base')?.getAttribute('href') || '/';
  var loginPath = new URL(
    'login',
    new URL(baseHref, window.location.origin),
  ).pathname;

  async function startClerk() {
    var timeout = window.setTimeout(function () {
      rejectReady(new Error('ClerkJS initialization timed out'));
    }, 20000);
    try {
      await loadScript(`${fapi}/npm/@clerk/ui@1.33.1/dist/ui.browser.js`);
      await loadScript(
        `${fapi}/npm/@clerk/clerk-js@6.32.1/dist/clerk.browser.js`,
        publishableKey,
      );
      var clerk = window.Clerk;
      if (!clerk) throw new Error('ClerkJS is unavailable');

      await clerk.load({
        ui: { ClerkUI: window.__internal_ClerkUICtor },
        signInUrl: loginPath,
        signUpUrl: loginPath,
        appearance: {
          variables: {
            colorPrimary: '#1B5A49',
            colorBackground: '#FFFEFA',
            colorText: '#182A23',
            borderRadius: '14px',
            fontFamily: 'DM Sans, sans-serif',
          },
          captcha: { language: 'pt-PT' },
        },
        localization: {
          locale: 'pt-PT',
          backButton: 'Voltar',
          formButtonPrimary: 'Continuar',
          formButtonPrimary__verify: 'Confirmar',
          formFieldAction__forgotPassword: 'Esqueceu-se da palavra-passe?',
          formFieldInputPlaceholder__emailAddress: 'nome@exemplo.pt',
          formFieldInputPlaceholder__password: 'Introduza a palavra-passe',
          formFieldInputPlaceholder__signUpPassword: 'Crie uma palavra-passe',
          formFieldLabel__confirmPassword: 'Confirme a palavra-passe',
          formFieldLabel__emailAddress: 'Endereço de email',
          formFieldLabel__firstName: 'Nome',
          formFieldLabel__lastName: 'Apelido',
          formFieldLabel__password: 'Palavra-passe',
          signIn: {
            emailCode: {
              formTitle: 'Código de verificação',
              resendButton: 'Não recebeu o código? Reenviar',
              subtitle: 'Introduza o código enviado para o seu email.',
              title: 'Verifique o seu email',
            },
            password: {
              actionLink: 'Usar outro método',
              subtitle: 'Introduza a palavra-passe associada à sua conta.',
              title: 'Introduza a palavra-passe',
            },
            start: {
              actionLink: 'Criar conta',
              actionText: 'Ainda não tem conta?',
              subtitle: 'Inicie sessão para continuar.',
              title: 'Iniciar sessão',
              titleCombined: 'Iniciar sessão',
            },
          },
          signUp: {
            emailCode: {
              formSubtitle: 'Introduza o código enviado para o seu endereço de email.',
              formTitle: 'Código de verificação',
              resendButton: 'Não recebeu o código? Reenviar',
              subtitle: 'Introduza o código enviado para o seu email.',
              title: 'Verifique o seu email',
            },
            start: {
              actionLink: 'Iniciar sessão',
              actionText: 'Já tem conta?',
              subtitle: 'Preencha os dados para criar a sua conta.',
              title: 'Crie a sua conta',
              titleCombined: 'Crie a sua conta',
            },
          },
        },
      });

      resolveReady({
        subscribe: function (callback) {
          clerk.addListener(function () {
            callback(JSON.stringify(serializeUser(clerk)));
          });
        },
        getUser: function () {
          return JSON.stringify(serializeUser(clerk));
        },
        getToken: function () {
          return clerk.session ? clerk.session.getToken() : Promise.resolve(null);
        },
        signIn: function () {
          clerk.openSignIn();
        },
        signUp: function () {
          clerk.openSignUp();
        },
        signOut: function () {
          return clerk.signOut();
        },
      });
    } catch (_) {
      rejectReady(new Error('ClerkJS could not initialize'));
    } finally {
      window.clearTimeout(timeout);
    }
  }

  if (document.readyState === 'complete') {
    startClerk();
  } else {
    window.addEventListener('load', startClerk, { once: true });
  }
})();
