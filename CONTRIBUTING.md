# Contributing to Firebase Backend

Obrigado por considerar contribuir com este pacote.

## Como contribuir

1. Faça um fork do repositório.
2. Crie uma branch descritiva:

```bash
git checkout -b feat/nome-da-melhoria
```

3. Implemente sua mudança mantendo o escopo pequeno e objetivo.
4. Atualize ou adicione testes quando aplicável.
5. Rode verificações locais antes de abrir PR:

```bash
flutter analyze
flutter test
```

6. Atualize a documentação relevante (`README.md`, exemplos, comentários, etc.).
7. Se houver mudança de comportamento público, atualize também o `CHANGELOG.md`.
8. Envie sua branch e abra um Pull Request para `main`.

## Diretrizes de código

- Siga os lints definidos em `analysis_options.yaml`.
- Prefira código simples, legível e com nomes explícitos.
- Evite breaking changes sem discussão prévia em issue.
- Trate erros de forma explícita e preserve a compatibilidade da API pública.

## Pull Requests

Para facilitar revisão, um PR deve:

- Explicar claramente o problema e a solução.
- Referenciar issue relacionada (quando existir).
- Incluir evidências de teste (saída de comandos ou descrição objetiva).
- Manter foco em uma única mudança lógica.

## Reporte de bugs e sugestões

- Bugs: abra uma issue com passos de reprodução, comportamento esperado e atual.
- Melhorias: abra uma issue descrevendo motivação e proposta.

## Código de conduta

Participe com respeito, colaboração e foco técnico. Contribuições ofensivas, abusivas ou discriminatórias não serão aceitas.
