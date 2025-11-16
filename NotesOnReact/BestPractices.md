# List of react best pratices by ByteGrad

Font: [YoutubeVideo](https://www.youtube.com/watch?v=5r25Y9Vg2P4)

## Hardcoded Consts and "Magic Numbers"

- Define constans/magic numbers/hardcoded values into its own file, or at least, outside the component. Prefer the separated file for this.

## Folder Structure

- Folder Structure: it should be consistent, there are many ways to organize a project, but you should be consistent on your methods. Also, keep in mind that it should be clear enough for new team members to understand the process.
- Have a lib folder for utils, types, and similar functions.
- Have context/stores/zustand/redux... folder for your state management tool.
- Every folder is separated by semantic meaning, and its quite obvious, keep it that way.

## Components and when to create them.

- In react, everything is about components. Components are independent pices of the UI.
- Keep the components reusable, or do not separated them if they are too small.
- Look for opportunities to reuse components (like buttons, or forms).
- Components maybe not reusable, but sometimes they are needed for organizations purposes, like sidebars, navbars, headers.
- Create components that help you organize markup.
- Use the children prop intelligently.
- Make components for elementes that are radically diferent.

## Avoid innecesary markups

- Avoid unnecesary divs.
- Use react fragments instead of unnecesary divs. Thats the best practice.

## Dont add layout styles to reusable components (grid, flex, margin, etc...)

- Add the layout style to another component that is not reusable or maybe, use a div (nice exeption).

- Note, react fragments do not accept styles or classes.

## use typescript:

- intellisense
- typescript for props, states, effects, memos, and other functions.

## Keep components simple:

- if they are reusable, keept it simple.
- handle complex logic on the parent component or functions in separated files (**folder structure**)
- keep setter/update functions on parent
- Use children pattern to avoid prop drilling (before using zustand or similar solutions)
-

## Naming functions when they are props

- keep the conventions of naming.
- Use handle for the state related functions
- Inside the component name the prop as the event it uses (onClick, onSubmit, onChange...)

## useMemo, useCallback, React.memo()

- useMemo to save resources and avoid recalculations for each re-render.
- React.memo for components as the two above and below.
- useCallback is the same but for functions, that way functions wont be recreated every time with each rerender.

## useState

- use updater function sintax is your new state depends on the last one.
- Think the best way to use the lesser number of states for an application.
- To select an item from a list, and mark it as selected, use only the id, or some unique value; not the entire object.
- In other words, keep an unique source of truth.

## Sometimes you need the URL instead of the useState:

- use a query parameter in the url to be able to share the page with the others and they receive the same view.
- If you do this, dont use useState. Remember, one source of truth.

## useEffect

- one useEffect per effect. No more than that, unless they are strictly related, and it if the case, review the code because they shouldnt be right? single responsability purpose.
- Avoid useEffect for fetching data, as it is not efficient as there is no caching there.
- prefer useQuery from react to fetch data.

## customHooks in react

- keep de "use" prefix for it.
- if they are needed for business logic or complex logic like fetching, write them, if not, well not.

## Component rules:

- Clean the markup
- Separate complex logic
- Reusable component
- if it is too simple, dont worry about it and keep it in the parent component.

## Logic, reusing logic:

- utility
- customHooks (logic + reactHooks)
- All inside lib.
