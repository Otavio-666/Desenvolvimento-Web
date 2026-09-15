document.addEventListener('DOMContentLoaded', () => {
    const envelope = document.getElementById('envelope');
    const typingText = document.getElementById('typing-text');
    const starsContainer = document.getElementById('stars');
    
    const message = "Obrigado por ser minha guia, meu porto seguro e o maior amor da minha vida. Você é a mulher mais forte que conheço e minha maior inspiração. Que seu dia seja repleto de sorrisos! Feliz Dia das Mães!";
    let hasOpened = false;

    // Gerar fundo estrelado
    for (let i = 0; i < 80; i++) {
        const star = document.createElement('div');
        star.className = 'star';
        const size = Math.random() * 3 + 'px';
        star.style.width = size;
        star.style.height = size;
        star.style.left = Math.random() * 100 + 'vw';
        star.style.top = Math.random() * 100 + 'vh';
        star.style.setProperty('--duration', Math.random() * 3 + 2 + 's');
        starsContainer.appendChild(star);
    }

    envelope.addEventListener('click', () => {
        if (!hasOpened) {
            envelope.classList.add('open');
            hasOpened = true;
            
            // Explosão de corações
            createExplosion();
            
            // Começa a digitar após a carta subir e ir para a frente (1 segundo)
            setTimeout(typeEffect, 1000);
        }
    });

    function typeEffect() {
        let i = 0;
        function type() {
            if (i < message.length) {
                typingText.innerHTML += message.charAt(i);
                i++;
                setTimeout(type, 50);
            }
        }
        type();
    }

    function createExplosion() {
        for (let i = 0; i < 20; i++) {
            const heart = document.createElement('div');
            heart.innerHTML = '❤️';
            heart.style.position = 'fixed';
            heart.style.left = '50%';
            heart.style.top = '50%';
            heart.style.fontSize = '24px';
            heart.style.zIndex = '100';
            document.body.appendChild(heart);

            const angle = Math.random() * Math.PI * 2;
            const dist = Math.random() * 200 + 100;
            const x = Math.cos(angle) * dist;
            const y = Math.sin(angle) * dist;

            heart.animate([
                { transform: 'translate(-50%, -50%) scale(1)', opacity: 1 },
                { transform: `translate(calc(-50% + ${x}px), calc(-50% + ${y}px)) scale(0)`, opacity: 0 }
            ], {
                duration: 1200,
                easing: 'ease-out'
            }).onfinish = () => heart.remove();
        }
    }
});